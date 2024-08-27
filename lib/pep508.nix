{
  lib,
  pep440,
  pep599,
  pypa,
  ...
}:

let
  inherit (builtins)
    match
    elemAt
    split
    foldl'
    substring
    stringLength
    typeOf
    fromJSON
    isString
    head
    mapAttrs
    elem
    length
    isList
    ;
  inherit (lib) stringToCharacters fix;
  inherit (import ./util.nix { inherit lib; }) splitComma stripStr;

  re = {
    operators = "([=><!~^]+)";
    version = "([0-9.*x]+)";
  };

  # Assign numerical priority values to logical conditions so we can do proper precedence ordering
  condPrio = {
    and = 5;
    or = 10;
    not = 1;
    "in" = -1;
    "not in" = -1;
    "" = -1;
  };
  condGt = l: r: if l == "" then false else condPrio.${l} >= condPrio.${r};

  # Parse a value into an attrset of { type = "valueType"; value = ...; }
  # Will parse any field name suffixed with "version" as a PEP-440 version, otherwise
  # the value is passed through and the type is inferred with builtins.typeOf
  parseValueVersionDynamic =
    name: value:
    if !isMarkerVariable name then
      throw "Unknown marker variable: ${name}"
    else
      (
        if name == "extra" then
          assert isList value || isString value;
          {
            type = "extra";
            inherit value;
          }
        else if match "^.+version" name != null && isString value then
          {
            type = "version";
            value = pep440.parseVersion value;
          }
        else
          {
            type = typeOf value;
            inherit value;
          }
      );

  # Remove groupings ( ) from expression
  unparen =
    let
      matchParen = match "[\t ]*\\((.+)\\)[\t ]*";
    in
    expr:
    let
      m = matchParen expr;
    in
    if m != null then head m else expr;

  isMarkerVariable =
    let
      markerFields = [
        "implementation_name"
        "implementation_version"
        "os_name"
        "platform_machine"
        "platform_python_implementation"
        "platform_release"
        "platform_system"
        "platform_version"
        "python_full_version"
        "python_version"
        "sys_platform"
        "extra"
      ];
    in
    s: elem s markerFields;

  unpackValue =
    value:
    if isMarkerVariable value then
      value
    else
      (
        let
          # If the value is a single ticked string we can't pass it plainly to toJSON.
          # Normalise to a double quoted.
          singleTicked = match "^'(.+)'$" value; # TODO: Account for escaped ' in input (unescape)
        in
        fromJSON (if singleTicked != null then "\"" + head singleTicked + "\"" else value)
      );

  # Comparators for simple equality
  # For versions see pep440.comparators
  comparators = {
    "==" = a: b: a == b;
    "!=" = a: b: a != b;
    "<=" = a: b: a <= b;
    ">=" = a: b: a >= b;
    "<" = a: b: a < b;
    ">" = a: b: a > b;
    "===" = a: b: a == b;
  };

  # Special case comparators for the `extra` environment field
  extraComparators = {
    # Check for member in list if list, otherwise simply compare.
    "==" = extras: extra: if typeOf extras == "list" then elem extra extras else extras == extra;
    "!=" = extras: extra: if typeOf extras == "list" then !(elem extra extras) else extras != extra;
  };

  boolOps = {
    "and" = x: y: x && y;
    "or" = x: y: x || y;
    "in" = x: y: lib.strings.hasInfix x y;
  };

  isPrimitiveType =
    let
      primitives = [
        "int"
        "float"
        "string"
        "bool"
      ];
    in
    type: elem type primitives;

in
fix (self: {

  /*
    Parse PEP 508 markers into an AST.

    Type: parseMarkers :: string -> AttrSet

    Example:
      # parseMarkers "(os_name=='a' or os_name=='b') and os_name=='c'"
      {
        lhs = {
          lhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "a";
            };
            type = "compare";
          };
          op = "or";
          rhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "b";
            };
            type = "compare";
          };
          type = "boolOp";
        };
        op = "and";
        rhs = {
          lhs = {
            type = "variable";
            value = "os_name";
          };
          op = "==";
          rhs = {
            type = "string";
            value = "c";
          };
          type = "compare";
        };
        type = "boolOp";
      }
  */
  parseMarkers =
    input:
    let
      # Find the positions of lhs/op/rhs in the input string
      pos' =
        foldl'
          (
            acc: c:
            let
              openP' = elemAt acc 0;
              inString' = elemAt acc 1;
              pos' = elemAt acc 2;
              cond' = elemAt acc 3;

              openP =
                if inString' then
                  openP'
                else
                  (
                    if c == "(" then
                      openP' + 1
                    else if c == ")" then
                      openP' - 1
                    else
                      openP'
                  );

              # # Look ahead to find the operator (either "and", "not" or "or").
              condSub = substring pos' 8 input; # 8 is the length of " not  in "
              cond =
                if openP > 0 || inString' then
                  ""
                else if match " and .+" condSub != null then
                  "and"
                else if match " or .+" condSub != null then
                  "or"
                else if match " in .+" condSub != null then
                  "in"
                else if match " not in .+" condSub != null then
                  "not in"
                else if match " not .+" condSub != null then
                  "not"
                else
                  "";

              # When we've reached the operator we know the start/end positions of lhs/op/rhs
              rhsOffset =
                if cond != "" && condGt cond cond' then
                  (
                    if (cond == "and" || cond == "not") then
                      5
                    else if (cond == "or" || cond == "in") then
                      4
                    else if cond == "not in" then
                      8
                    else
                      throw "Unknown cond: ${cond}"
                  )
                else
                  -1;

            in
            [
              # If we are inside a string don't track the opening and closing of parens
              # openP =
              openP

              # Check opening and closing of strings
              # inString =
              (
                if inString' && c == "'" then
                  true
                else if !inString' && c == "'" then
                  false
                else
                  inString'
              )

              #pos =
              (pos' + 1)

              # cond =
              (if cond != "" then cond else cond')

              # lhs =
              (if (rhsOffset != -1) then pos' else (elemAt acc 4))
              #rhs =
              (if (rhsOffset != -1) then (pos' + rhsOffset) else (elemAt acc 5))
            ]
          )
          [
            0 # openP: Number of open parens
            false # inString: If the parser is inside a string
            0 # pos: Parser position

            # Keep track of last logical condition to do precedence ordering
            "" # cond

            # Stop positions for each value
            (-1) # lhs
            (-1) # rhs
          ]
          (stringToCharacters input);

      posLhs = elemAt pos' 4;
      posRhs = elemAt pos' 5;

    in
    if posLhs == -1 then # No right hand value to extract
      (
        let
          m = split re.operators (unparen input);
          mLength = length m;
          lhs = stripStr (elemAt m 0);
        in
        if (mLength > 1) then
          assert mLength == 3;
          {
            type = "compare";
            lhs =
              if isMarkerVariable lhs then
                {
                  type = "variable";
                  value = lhs;
                }
              else
                unpackValue lhs;
            op = elemAt (elemAt m 1) 0;
            rhs = parseValueVersionDynamic lhs (unpackValue (stripStr (elemAt m 2)));
          }
        else if isMarkerVariable input then
          {
            type = "variable";
            value = input;
          }
        else
          rec {
            value = unpackValue input;
            type = typeOf value;
          }
      )
    else
      {
        type = "boolOp";
        lhs = self.parseMarkers (unparen (substring 0 posLhs input));
        op = substring (posLhs + 1) (posRhs - posLhs - 2) input;
        rhs = self.parseMarkers (unparen (substring posRhs (stringLength input) input));
      };

  /*
    Parse a PEP-508 dependency string.

    Type: parseString :: string -> AttrSet

    Example:
      # parseString "cachecontrol[filecache]>=0.13.0"
      {
        conditions = [
          {
            op = ">=";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 0 13 0 ];
            };
          }
        ];
        markers = null;
        name = "cachecontrol";
        extras = [ "filecache" ];
        url = null;
      }
  */
  parseString =
    input:
    let
      # Split the input into it's distinct parts: The package segment, URL and environment markers
      tokens =
        let
          # Input has both @ and ; separators (both URL and markers)
          # "name [fred,bar] @ http://foo.com ; python_version=='2.7'"
          m1 = match "^(.+)@(.+);(.+)$" input;

          # Input has ; separator (markers)
          # "name [fred,bar] ; python_version=='2.7'"
          m2 = match "^(.+);(.+)$" input;

          # Input has @ separator (URL)
          # "name [fred,bar] @ http://foo.com"
          m3 = match "^(.+)@(.+)$" input;

        in
        if m1 != null then
          {
            packageSegment = elemAt m1 0;
            url = stripStr (elemAt m1 1);
            markerSegment = elemAt m1 2;
          }
        else if m2 != null then
          {
            packageSegment = elemAt m2 0;
            url = null;
            markerSegment = elemAt m2 1;
          }
        else if m3 != null then
          {
            packageSegment = elemAt m3 0;
            url = stripStr (elemAt m3 1);
            markerSegment = null;
          }
        else
          (
            if match ".+\/.+" input != null then
              # Input is a bare URL
              {
                packageSegment = null;
                url = input;
                markerSegment = null;
              }
            else
              # Input is a package name
              {
                packageSegment = input;
                url = null;
                markerSegment = null;
              }
          );

      # Extract metadata from the package segment
      package =
        let
          # Package has either both extras and version constraints or just extras
          # "name [fred,bar]>=3.10"
          # "name [fred,bar]"
          m1 = match "(.+)\\[(.*)](.*)" tokens.packageSegment;

          # Package has either version constraints or is bare
          # "name>=3.2"
          # "name"
          m2 = match "([a-zA-Z0-9_\\.-]+)(.*)" tokens.packageSegment;

          # The version conditions as a list of strings
          conditions = pep440.parseVersionConds (if m1 != null then elemAt m1 2 else elemAt m2 1);

          # Extras as a list of strings
          #
          # Based on PEP-508 alone it's not clear whether extras should be normalized or not.
          # From discussion in https://github.com/pypa/packaging-problems/issues/230
          # missing normalization seems like an oversight.
          extras = if m1 != null then map pypa.normalizePackageName (splitComma (elemAt m1 1)) else [ ];

        in
        if tokens.packageSegment == null then
          {
            name = null;
            conditions = [ ];
            extras = [ ];
          }
        else
          # Assert that either regex matched
          assert m1 != null || m2 != null;
          {
            # Based on PEP-508 alone it's not clear whether names should be normalized or not.
            # From discussion in https://github.com/pypa/packaging-problems/issues/230
            # this seems like an oversight and we _should_ actually canonicalize names at parse time.
            name = pypa.normalizePackageName (stripStr (if m1 != null then elemAt m1 0 else elemAt m2 0));
            inherit extras conditions;
          };

    in
    {
      name =
        if package.name != null then
          package.name
        # Infer name from URL if no name was specified explicitly
        else if tokens.url != null then
          (
            let
              inherit (tokens) url;
              mEggFragment = match ".+#egg=(.+)" url;
            in
            if mEggFragment != null then elemAt mEggFragment 0 else null
          )
        else
          null;
      inherit (package) conditions extras;
      inherit (tokens) url;
      markers = if tokens.markerSegment == null then null else self.parseMarkers tokens.markerSegment;
    };

  /*
    Create an attrset of platform variables.
    As described in https://peps.python.org/pep-0508/#environment-markers.

    Type: mkEnviron :: derivation -> AttrSet

    Example:
      # mkEnviron pkgs.python3
      {
        implementation_name = {
          type = "string";
          value = "cpython";
        };
        implementation_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 10 12 ];
          };
        };
        os_name = {
          type = "string";
          value = "posix";
        };
        platform_machine = {
          type = "string";
          value = "x86_64";
        };
        platform_python_implementation = {
          type = "string";
          value = "CPython";
        };
        # platform_release maps to platform.release() which returns
        # the running kernel version on Linux.
        # Because this field is not reproducible it's left empty.
        platform_release = {
          type = "string";
          value = "";
        };
        platform_system = {
          type = "string";
          value = "Linux";
        };
        # platform_version maps to platform.version() which also returns
        # the running kernel version on Linux.
        # Because this field is not reproducible it's left empty.
        platform_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ ];
          };
        };
        python_full_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 10 12 ];
          };
        };
        python_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 10 ];
          };
        };
        sys_platform = {
          type = "string";
          value = "linux";
        };
      }
  */
  mkEnviron =
    python:
    let
      inherit (python) stdenv;
      inherit (stdenv) targetPlatform;
      impl = python.passthru.implementation;
    in
    mapAttrs parseValueVersionDynamic {
      os_name = if python.pname == "jython" then "java" else "posix";
      sys_platform =
        if stdenv.isLinux then
          "linux"
        else if stdenv.isDarwin then
          "darwin"
        else
          throw "Unsupported platform";
      platform_machine =
        if targetPlatform.isDarwin then
          targetPlatform.darwinArch
        else
          pep599.manyLinuxTargetMachines.${targetPlatform.parsed.cpu.name} or targetPlatform.parsed.cpu.name;
      platform_python_implementation =
        if impl == "cpython" then
          "CPython"
        else if impl == "pypy" then
          "PyPy"
        else
          throw "Unsupported implementation ${impl}";
      platform_release = ""; # Field not reproducible
      platform_system =
        if stdenv.isLinux then
          "Linux"
        else if stdenv.isDarwin then
          "Darwin"
        else
          throw "Unsupported platform";
      platform_version = ""; # Field not reproducible
      python_version = python.passthru.pythonVersion;
      python_full_version = python.version;
      implementation_name = python.passthru.implementation;
      implementation_version = python.version;
    };

  /*
    Update one or more keys in an environment created by mkEnviron.

    Example:
      # setEnviron (mkEnviron pkgs.python3) { platform_release = "5.10.65";  }
  */
  setEnviron = environ: updates: environ // mapAttrs parseValueVersionDynamic updates;

  /*
    Evaluate an environment as returned by `mkEnviron` against markers as returend by `parseMarkers`.

    Type: evalMarkers :: AttrSet -> AttrSet -> bool

    Example:
      # evalMarkers (mkEnviron pkgs.python3) (parseMarkers "python_version < \"3.11\"")
      true
  */
  evalMarkers =
    environ: value:
    (
      let
        x = self.evalMarkers environ value.lhs;
        y = self.evalMarkers environ value.rhs;
      in
      if value.type == "compare" then
        (
          (
            # Version comparison
            if value.lhs.type == "version" || value.rhs.type == "version" then
              pep440.comparators.${value.op}
            # `Extra` environment marker comparison requires special casing because it's equality checks can
            # == can be considered a `"key" in set` comparison when multiple extras are activated for a dependency.
            # If we didn't treat it this way the check would become quadratic as `evalMarkers` only could check one extra at a time.
            else if value.lhs.type == "variable" || value.lhs.value == "extra" then
              extraComparators.${value.op}
            # Simple equality
            else
              comparators.${value.op}
          )
          x
          y
        )
      else if value.type == "boolOp" then
        boolOps.${value.op} x y
      else if value.type == "variable" then
        (self.evalMarkers environ environ.${value.value})
      else if value.type == "version" || value.type == "extra" then
        value.value
      else if isPrimitiveType value.type then
        value.value
      else
        throw "Unknown type '${value.type}'"
    );

})
