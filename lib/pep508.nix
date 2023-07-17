{ lib }:

let
  inherit (builtins) match elemAt split filter foldl' substring stringLength;

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

  # Strip leading/trailing whitespace from string
  stripStr = s: lib.elemAt (builtins.split "^ *" (lib.elemAt (builtins.split " *$" s) 0)) 2;

  # Split a comma separated string
  splitComma = s: if s == "" then [ ] else filter (x: lib.isString x && x != "" && x != " ") (split "(,)|(, *)|( *,)|( *, *)" s);

  # Remove groupings ( ) from expression
  unparen = expr':
    let
      expr = stripStr expr';
      m = builtins.match "\\((.+)\\)" expr;
    in
    if m != null then elemAt m 0 else expr;

  # Parse grouped expressions
  #
  # Example input: "name [fred,bar] @ http://foo.com ; python_version=='2.7'"
  # For output see tests below.
  parseMarkers = input:
    let
      # Find the positions of lhs/op/rhs in the input string
      pos = (
        foldl'
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
          (lib.stringToCharacters input)
      );

    in
    (
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
        lhs = parseMarkers (unparen (substring 0 pos.lhs input));
        op = substring (pos.lhs + 1) (pos.rhs - pos.lhs - 2) input;
        rhs = parseMarkers (unparen (substring pos.rhs (stringLength input) input));
      }
    );

in
(lib.fix (self: {

  # Example input
  # "name [fred,bar] @ http://foo.com ; python_version=='2.7'"
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
        (
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
          }
        );

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
      markers = if tokens.markerSegment == null then null else parseMarkers tokens.markerSegment;
    };

  tests = lib.mapAttrs (_: case: case // { output = self.parseString case.input; }) {
    simple = {
      input = "blinker";
      expected = {
        name = "blinker";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    versioned = {
      input = "rich>=12.3.0";
      expected = {
        name = "rich";
        conditions = [
          {
            op = ">=";
            version = "12.3.0";
          }
        ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    withExtras = {
      input = "mkdocstrings[python]";
      expected = {
        name = "mkdocstrings";
        conditions = [ ];
        optionals = [ "python" ];
        markers = null;
        url = null;
      };
    };

    versionedWithDoubleConditions = {
      input = "packaging>=20.9,!=22.0";
      expected = {
        name = "packaging";
        conditions = [
          {
            op = ">=";
            version = "20.9";
          }
          {
            op = "!=";
            version = "22.0";
          }
        ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    versionedWithExtras = {
      input = "cachecontrol[filecache]>=0.13.0";
      expected = {
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
      };
    };

    versionedWithMarker = {
      input = "tomli>=1.1.0; python_version < \"3.11\"";
      expected = {
        name = "tomli";
        conditions = [
          {
            op = ">=";
            version = "1.1.0";
          }
        ];
        optionals = [ ];
        markers = {
          op = "<";
          lhs = "python_version";
          rhs = "\"3.11\"";
        };
        url = null;
      };
    };

    nameWithURL = {
      input = "name@http://foo.com";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = "http://foo.com";
      };
    };

    dottedNames = {
      input = "A.B-C_D";
      expected = {
        name = "A.B-C_D";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    completeExample = {
      input = "name [fred,bar] @ http://foo.com ; python_version=='2.7'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ "fred" "bar" ];
        markers = {
          op = "==";
          lhs = "python_version";
          rhs = "'2.7'";
        };
        url = "http://foo.com";
      };
    };

    doubleMarkers = {
      input = "name; os_name=='a' or os_name=='b'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
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
        url = null;
      };
    };

    doubleMarkersWithOptionals = {
      input = "name[quux, strange];python_version<'2.7' and platform_version=='2'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ "quux" "strange" ];
        markers = {
          op = "and";
          lhs = {
            op = "<";
            lhs = "python_version";
            rhs = "'2.7'";
          };
          rhs = {
            op = "==";
            lhs = "platform_version";
            rhs = "'2'";
          };
        };
        url = null;
      };
    };

    exprGroups = {
      # Should parse as (a and b) or c
      input = "name; os_name=='a' and os_name=='b' or os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "or";
          lhs = {
            op = "and";
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
        };
        url = null;
      };
    };

    exprGroupsInt = {
      # Overriding precedence -> a and (b or c)
      input = "name; os_name=='a' and (os_name=='b' or os_name=='c')";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "and";
          lhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'a'";
          };
          rhs = {
            op = "or";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'c'";
            };
          };
        };
        url = null;
      };
    };

    exprGroupsTail = {
      # should parse as a or (b and c)
      input = "name; os_name=='a' or os_name=='b' and os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "or";
          lhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'a'";
          };
          rhs = {
            op = "and";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'c'";
            };
          };
        };
        url = null;
      };
    };

    exprGroupsHead = {
      # Overriding precedence -> (a or b) and c
      input = "name; (os_name=='a' or os_name=='b') and os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
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
        };
        url = null;
      };
    };

  };
}))
