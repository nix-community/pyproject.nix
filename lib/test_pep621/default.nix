{
  lib,
  pep508,
  pep621,
  fixtures,
  mocks,
  pypa,
  ...
}:
let
  inherit (builtins) mapAttrs readDir;
  inherit (pep621) parseDependencies parseRequiresPython filterDependenciesByEnviron;
  inherit (lib) fix;

  getDependenciesNames =
    let
      normalize = pypa.normalizePackageName;
      getNames = map (dep: normalize dep.name);
    in
    dependencies: {
      dependencies = getNames dependencies.dependencies;
      extras = mapAttrs (_: getNames) dependencies.extras;
      build-systems = getNames dependencies.build-systems;
    };

  expected = mapAttrs (name: _: import ./expected/${name}) (readDir ./expected);
in
fix (_self: {
  parseDependencies = {
    testPandas = {
      expr = parseDependencies { pyproject = fixtures."pandas.toml"; };
      expected = expected."parsedependencies-pandas.nix";
    };

    testPdm = {
      expr = parseDependencies { pyproject = fixtures."pdm.toml"; };
      expected = expected."parsedependencies-pdm.nix";
    };
  };

  parseRequiresPython = {
    testPandas = {
      expr = parseRequiresPython fixtures."pandas.toml";
      expected = [
        {
          op = ">=";
          version = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [
              3
              9
            ];
            str = "3.9";
          };
        }
      ];
    };

    testPdm = {
      expr = parseRequiresPython fixtures."pdm.toml";
      expected = [
        {
          op = ">=";
          version = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [
              3
              7
            ];
            str = "3.7";
          };
        }
      ];
    };
  };

  # Covered by the other tests, mock for coverage
  filterDependenciesListByEnviron = {
    testDummy = {
      expr = true;
      expected = true;
    };
  };

  # Use name normalization in tests to ensure we don't have huge expected outputs
  filterDependenciesByEnviron = {
    testPdmCpythonLinux38 = {
      expr = getDependenciesNames (
        filterDependenciesByEnviron (pep508.mkEnviron mocks.cpythonLinux38) [ ] (
          pep621.parseDependencies { pyproject = fixtures."pdm.toml"; }
        )
      );
      expected = {
        build-systems = [ "pdm-backend" ];
        dependencies = [
          "blinker"
          "certifi"
          "packaging"
          "platformdirs"
          "rich"
          "virtualenv"
          "pyproject-hooks"
          "requests-toolbelt"
          "unearth"
          "findpython"
          "tomlkit"
          "shellingham"
          "python-dotenv"
          "resolvelib"
          "installer"
          "cachecontrol"
          "tomli"
          "importlib-resources"
          "importlib-metadata"
        ];
        extras = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          keyring = [ "keyring" ];
          pytest = [
            "pytest"
            "pytest-mock"
          ];
          template = [ "pdm" ];
          truststore = [ ];
        };
      };
    };

    testPdmDarwin311 = {
      expr = getDependenciesNames (
        filterDependenciesByEnviron (pep508.mkEnviron mocks.cpythonDarwin311) [ ] (
          pep621.parseDependencies { pyproject = fixtures."pdm.toml"; }
        )
      );
      expected = {
        build-systems = [ "pdm-backend" ];
        dependencies = [
          "blinker"
          "certifi"
          "packaging"
          "platformdirs"
          "rich"
          "virtualenv"
          "pyproject-hooks"
          "requests-toolbelt"
          "unearth"
          "findpython"
          "tomlkit"
          "shellingham"
          "python-dotenv"
          "resolvelib"
          "installer"
          "cachecontrol"
        ];
        extras = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          keyring = [ "keyring" ];
          pytest = [
            "pytest"
            "pytest-mock"
          ];
          template = [ "pdm" ];
          truststore = [ "truststore" ];
        };
      };
    };
  };
})
