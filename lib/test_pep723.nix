{
  pep723,
  pep440,
  pep508,
  ...
}:

let
  # We're re-using the same dependency declarations in all test, inline fixtures.
  requiresPython = pep440.parseVersionConds ">=3.11";
  requests = pep508.parseString "requests<3";
  rich = pep508.parseString "rich";

in
{
  parseScript = {
    # A simple script
    testScript = {
      expr = pep723.parseScript ''
        # /// script
        # requires-python = ">=3.11"
        # dependencies = [
        #   "requests<3",
        #   "rich",
        # ]
        # ///
        import requests
        import rich
        print("Hello world")
      '';
      expected = {
        requires-python = requiresPython;
        dependencies = [
          requests
          rich
        ];
      };
    };

    # A simple script with no actual body
    testScriptNoBody = {
      expr = pep723.parseScript ''
        # /// script
        # requires-python = ">=3.11"
        # dependencies = [
        #   "requests<3",
        #   "rich",
        # ]
        # ///
      '';
      expected = {
        requires-python = requiresPython;
        dependencies = [
          requests
          rich
        ];
      };
    };

    # A simple script with no metadata section
    testDefaultMetadata = {
      expr = pep723.parseScript ''
        print("Hello world")
      '';
      expected = {
        requires-python = [ ];
        dependencies = [ ];
      };
    };

    testMissingRequiresPython = {
      expr = pep723.parseScript ''
        # /// script
        # dependencies = [
        #   "rich",
        # ]
        # ///
      '';
      expected = {
        requires-python = [ ];
        dependencies = [ rich ];
      };
    };

    testMissingDependencies = {
      expr = pep723.parseScript ''
        # /// script
        # requires-python = ">=3.11"
        # ///
      '';
      expected = {
        requires-python = requiresPython;
        dependencies = [ ];
      };
    };

    # A script with a shebang and a script section offset from the initial comment block
    testOffsetScript = {
      expr = pep723.parseScript ''
        #!/usr/bin/env python3

        # /// script
        # requires-python = ">=3.11"
        # dependencies = [
        #   "requests<3",
        #   "rich",
        # ]
        # ///
      '';
      expected = {
        requires-python = requiresPython;
        dependencies = [
          requests
          rich
        ];
      };
    };

    # Note the empty line in the script.
    testHolyMetadata = {
      expr = pep723.parseScript ''
        # /// script
        # requires-python = ">=3.11"
        # dependencies = [
        #   "requests<3",

        #   "rich",
        # ]
        # ///
      '';
      expected = {
        requires-python = requiresPython;
        dependencies = [
          requests
          rich
        ];
      };
    };
  };
}
