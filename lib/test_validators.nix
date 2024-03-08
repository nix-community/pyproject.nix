{ project
, fixtures
, validators
, mocks
, ...
}:
let
  inherit (project) loadPyproject;

  projects = {
    pdm = loadPyproject {
      pyproject = fixtures."pdm.toml";
      extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
    };
    pandas = loadPyproject { pyproject = fixtures."pandas.toml"; };
  };

in
{
  validateVersionConstraints = {
    testPdm = {
      expr = validators.validateVersionConstraints {
        project = projects.pdm;
        python = mocks.cpythonLinux38;
      };
      expected = {
        resolvelib = {
          conditions = [{ op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 1 0 1 ]; }; }];
          version = "0.5.5";
        };
        unearth = {
          conditions = [{ op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 0 10 0 ]; }; }];
          version = "0.9.1";
        };
      };
    };
  };
}
