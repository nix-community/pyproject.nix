{ pip, ... }:
let
  inherit (pip) parseRequirementsTxt;

in
{
  parseRequirementsTxt = {
    testBasic = {
      expr = parseRequirementsTxt ''
        FooProject == 1.2 \
          --hash=sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 \
          --hash=sha256:486ea46224d1bb4fb680f34f7c9ad96a8f24ec88be73ea8e5a6c65260e9cb8a7

        Bar == 3.2 \
          --hash=sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 \
          --hash=sha256:486ea46224d1bb4fb680f34f7c9ad96a8f24ec88be73ea8e5a6c65260e9cb8a7
      '';
      expected = [
        {
          flags = [
            "--hash=sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
            "--hash=sha256:486ea46224d1bb4fb680f34f7c9ad96a8f24ec88be73ea8e5a6c65260e9cb8a7"
          ];
          requirement = {
            conditions = [
              {
                op = "==";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [
                    1
                    2
                  ];
                  str = "1.2";
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "fooproject";
            url = null;
          };
        }
        {
          flags = [
            "--hash=sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
            "--hash=sha256:486ea46224d1bb4fb680f34f7c9ad96a8f24ec88be73ea8e5a6c65260e9cb8a7"
          ];
          requirement = {
            conditions = [
              {
                op = "==";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [
                    3
                    2
                  ];
                  str = "3.2";
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "bar";
            url = null;
          };
        }
      ];
    };

    testRecursive = {
      expr = parseRequirementsTxt ./fixtures/requirements-recursive.txt;
      expected = [
        {
          flags = [ ];
          requirement = {
            conditions = [
              {
                op = "==";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [
                    10
                    1
                    0
                  ];
                  str = "10.1.0";
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "pillow";
            url = null;
          };
        }
        {
          flags = [ ];
          requirement = {
            conditions = [
              {
                op = "==";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [
                    2
                    31
                    0
                  ];
                  str = "2.31.0";
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "requests";
            url = null;
          };
        }
      ];
    };
  };
}
