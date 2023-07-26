{ project
, fixtures
, ...
}:
let
  inherit (builtins) typeOf;
  inherit (project) loadPyproject;

  isSet = s: typeOf s == "set";
  isList = l: typeOf l == "list";

in
{
  loadPyproject = {
    testPdm = {
      expr =
        let
          project = loadPyproject { pyproject = fixtures."pdm.toml"; };
        in
        assert isSet project.pyproject;
        assert isSet project.dependencies;
        assert isList project.build-systems;
        null;
      expected = null;
    };

    testPandas = {
      expr =
        let
          project = loadPyproject { pyproject = fixtures."pandas.toml"; };
        in
        assert isSet project.pyproject;
        assert isSet project.dependencies;
        assert isList project.build-systems;
        null;
      expected = null;
    };
  };
}
