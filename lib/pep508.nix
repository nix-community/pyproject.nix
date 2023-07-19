{ lib }:

let
  inherit (builtins) match hasAttr elemAt split filter foldl' substring stringLength typeOf compareVersions fromJSON isString head;
  inherit (lib) stringToCharacters fix;

  re = {
    operators = "([=><!~^]+)";
    version = "([0-9.*x]+)";
  };

  # Assign numerical priority values to logical conditions so we can do proper precedence ordering
  condPrio = {
    and = 5;
    or = 10;
    not = 1;
    "" = -1;
  };
  condGt = l: r: if l == "" then false else condPrio.${l} >= condPrio.${r};

  isEmptyStr = s: isString s && match " *" s == null;

  # Strip leading/trailing whitespace from string
  stripStr = s: let t = match "[\t ]*(.*[^\t ])[\t ]*" s; in if t == null then "" else head t;

  # Split a comma separated string
  splitComma = s: if s == "" then [ ] else filter isEmptyStr (split " *, *" s);

  # Remove groupings ( ) from expression
  unparen = expr':
    let
      expr = stripStr expr';
      m = match "\\((.+)\\)" expr;
    in
    if m != null then elemAt m 0 else expr;

  # Maps Nixpkgs CPU values to target machines known to be supported for manylinux* wheels.
  # (a.k.a. `uname -m` output from CentOS 7)
  #
  # This is current as of manylinux2014 (PEP-0599), and is a superset of manylinux2010 / manylinux1.
  # s390x is not supported in Nixpkgs, so we don't map it.
  manyLinuxTargetMachines = {
    x86_64 = "x86_64";
    i686 = "i686";
    aarch64 = "aarch64";
    armv7l = "armv7l";
    powerpc64 = "ppc64";
    powerpc64le = "ppc64le";
  };

  # Marker eval operations
  operations = {
    # Simple equality
    "==" = x: y: x == y;

    # These implicitly means version compare and not just arbitrary lt/gt
    "<=" = x: y: compareVersions x y <= 0;
    "<" = x: y: compareVersions x y < 0;
    ">=" = x: y: compareVersions x y >= 0;
    ">" = x: y: compareVersions x y > 0;

    # Logical conditions
    "and" = x: y: x && y;
    "or" = x: y: x || y;
  };

in
fix (self:
let

  # Process a value from evalMarkers
  # These functions are mutually recursive.
  processValue = value: environ:
    let
      type = typeOf value;
      # If the value is a single ticked string we can't pass it plainly to toJSON
      singleTicked = match "^'(.+)'$" value; # TODO: Account for escaped ' in input (unescape)
    in
    # If the value is a set it's a sub expression, call back to evalMarkers
    if type == "set" then (self.evalMarkers environ value)
    # If the value is a string it means we have arrived at an actual value
    else if type == "string" then
      (
        # Try to look up the value from the platform environment
        # If this doesn't exist unmarshal the value
        if (hasAttr value environ) then environ.${value} else
        (
          if singleTicked != null then elemAt singleTicked 0 else fromJSON value
        )
      )
    else throw "${type}: ${value}";

in
{

  /* Parse PEP 508 markers into an AST.

     Type: parseMarkers :: string -> AttrSet

     Example:
       # parseMarkers "(os_name=='a' or os_name=='b') and os_name=='c'"
       {
          op = "and";
          lhs = {
            op = "or";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'a'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
          };
          rhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'c'";
          };
        }
  */
  parseMarkers = input:
    let
      # Find the positions of lhs/op/rhs in the input string
      pos = foldl'
        (acc: c:
          let
            # # Look ahead to find the operator (either "and", "not" or "or").
            cond =
              if self.openP > 0 || acc.inString then ""
              else if substring acc.pos 5 input == " and " then "and"
              else if substring acc.pos 4 input == " or " then "or"
              else if substring acc.pos 5 input == " not " then "not"
              else "";

            # When we've reached the operator we know the start/end positions of lhs/op/rhs
            rhsOffset =
              if cond != "" && condGt cond acc.cond then
                (
                  if (cond == "and" || cond == "not") then 5
                  else if (cond == "or") then 4
                  else throw "Unknown cond: ${cond}"
                ) else -1;

            self = {
              # If we are inside a string don't track the opening and closing of parens
              openP = if acc.inString then acc.openP else
              (
                if c == "(" then acc.openP + 1
                else if c == ")" then acc.openP - 1
                else acc.openP
              );

              # Check opening and closing of strings
              inString =
                if acc.inString && c == "'" then true
                else if !acc.inString && c == "'" then false
                else acc.inString;

              pos = acc.pos + 1;

              cond = if cond != "" then cond else acc.cond;

              lhs = if (rhsOffset != -1) then acc.pos else acc.lhs;
              rhs = if (rhsOffset != -1) then (acc.pos + rhsOffset) else acc.rhs;
            };

          in
          self)
        {
          openP = 0; # Number of open parens
          inString = false; # If the parser is inside a string
          pos = 0; # Parser position
          done = false;

          # Keep track of last logical condition to do precedence ordering
          cond = "";

          # Stop positions for each value
          lhs = -1;
          rhs = -1;

        }
        (stringToCharacters input);

    in
    if pos.lhs == -1 then
      (
        let # Value is a comparison
          m = split re.operators (unparen input);
        in
        {
          lhs = stripStr (elemAt m 0);
          op = elemAt (elemAt m 1) 0;
          rhs = stripStr (elemAt m 2);
        }
      ) else {
      # Value is an expression group
      lhs = self.parseMarkers (unparen (substring 0 pos.lhs input));
      op = substring (pos.lhs + 1) (pos.rhs - pos.lhs - 2) input;
      rhs = self.parseMarkers (unparen (substring pos.rhs (stringLength input) input));
    };

  /* Parse a PEP-508 dependency string.

     Type: parseString :: string -> AttrSet

     Example:
       # parseString "cachecontrol[filecache]>=0.13.0"
       {
          name = "cachecontrol";
          conditions = [
            {
              op = ">=";
              version = "0.13.0";
            }
          ];
          optionals = [ "filecache" ];
          markers = null;
          url = null;
        }
  */
  parseString = input:
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
        if m1 != null then {
          packageSegment = elemAt m1 0;
          url = stripStr (elemAt m1 1);
          markerSegment = elemAt m1 2;
        }
        else if m2 != null then {
          packageSegment = elemAt m2 0;
          url = null;
          markerSegment = elemAt m2 1;
        }
        else if m3 != null then {
          packageSegment = elemAt m3 0;
          url = stripStr (elemAt m3 1);
          markerSegment = null;
        }
        else {
          packageSegment = input;
          url = null;
          markerSegment = null;
        };

      # Extract metadata from the package segment
      package =
        let
          # Package has either both optionals and version constraints or just optionals
          # "name [fred,bar]>=3.10"
          # "name [fred,bar]"
          m1 = match "(.+)\\[(.*)](.*)" tokens.packageSegment;

          # Package has either version constraints or is bare
          # "name>=3.2"
          # "name"
          m2 = match "([a-zA-Z0-9_\\.-]+)(.*)" tokens.packageSegment;

          # The version conditions as a list of strings
          conditions = map
            (cond:
              let
                m = match "${re.operators}(.+)" cond;
              in
              {
                op = elemAt m 0;
                version = elemAt m 1;
              })
            (splitComma (if m1 != null then elemAt m1 2 else elemAt m2 1));

          # Optionals as a list of strings
          optionals = if m1 != null then splitComma (elemAt m1 1) else [ ];

        in
        # Assert that either regex matched
        assert m1 != null || m2 != null; {
          name = stripStr (if m1 != null then elemAt m1 0 else elemAt m2 0);
          inherit optionals conditions;
        };

    in
    {
      inherit (package) name conditions optionals;
      inherit (tokens) url;
      markers = if tokens.markerSegment == null then null else self.parseMarkers tokens.markerSegment;
    };

  /* Create an attrset of platform variables.
     As described in https://peps.python.org/pep-0508/#environment-markers.

     Type: mkEnviron :: derivation -> AttrSet

     Example:
       # mkEnviron pkgs.python3
       {
         implementation_name = "cpython";
         implementation_version = "3.8.2";
         os_name = "posix";
         platform_machine = "x86_64";
         platform_python_implementation = "CPython";
         platform_release = "";
         platform_system = "Linux";
         platform_version = "";
         python_full_version = "3.8.2";
         python_version = "3.8";
         sys_platform = "linux";
       }
  */
  mkEnviron = python:
    let
      inherit (python) stdenv;
      targetMachine = manyLinuxTargetMachines.${stdenv.targetPlatform.parsed.cpu.name} or null;
    in
    {
      os_name =
        if python.pname == "jython" then "java"
        else "posix";
      sys_platform =
        if stdenv.isLinux then "linux"
        else if stdenv.isDarwin then "darwin"
        else throw "Unsupported platform";
      platform_machine = targetMachine;
      platform_python_implementation =
        let
          impl = python.passthru.implementation;
        in
        if impl == "cpython" then "CPython"
        else if impl == "pypy" then "PyPy"
        else throw "Unsupported implementation ${impl}";
      platform_release = ""; # Field not reproducible
      platform_system =
        if stdenv.isLinux then "Linux"
        else if stdenv.isDarwin then "Darwin"
        else throw "Unsupported platform";
      platform_version = ""; # Field not reproducible
      python_version = python.passthru.pythonVersion;
      python_full_version = python.version;
      implementation_name = python.passthru.implementation;
      implementation_version = python.version;
    };

  /* Evaluate an environment as returned by `mkEnviron` against markers as returend by `parseMarkers`.

     Type: evalMarkers :: AttrSet -> AttrSet -> bool

     Example:
       # evalMarkers (mkEnviron pkgs.python3) (parseMarkers "python_version < \"3.11\"")
       true
  */
  evalMarkers = environ: marker: operations.${marker.op} (processValue marker.lhs environ) (processValue marker.rhs environ);
})
