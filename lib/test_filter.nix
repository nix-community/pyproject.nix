{ lib
, filter
, fixtures
, mocks
, pep508
, pep621
, ...
}:
let
  inherit (filter) filterDependenciesByEnviron filterDependenciesByExtras;

in
lib.fix (_self: {
  # Note that we're not strictly using the supported data structure here just to make the tests smaller.
  # It's just a special case application of filterAttrs anyway so it's a simple function.
  filterDependenciesByExtras = {
    testSimple = {
      expr = filterDependenciesByExtras [ ] {
        dependencies = [ "requests" ];
        extras = {
          dev = [ "pytest" ];
        };
      };
      expected = {
        dependencies = [ "requests" ];
        extras = { };
      };
    };
  };

  # Covered by the other tests, mock for coverage
  filterDependencies = {
    testDummy = {
      expr = true;
      expected = true;
    };
  };
  filterDependenciesListByEnviron = {
    testDummy = {
      expr = true;
      expected = true;
    };
  };

  # Use name normalization in tests to ensure we don't have huge expected outputs
  filterDependenciesByEnviron = {
    testPdmCpythonLinux38 = {
      expr = pep621.getDependenciesNamesNormalized (
        filterDependenciesByEnviron
          (pep508.mkEnviron mocks.cpythonLinux38)
          (pep621.parseDependencies {
            pyproject = fixtures."pdm.toml";
          })
      );
      expected = {
        build-systems = [ "pdm-backend" ];
        dependencies = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
        extras = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          keyring = [ "keyring" ];
          pytest = [ "pytest" "pytest-mock" ];
          template = [ "pdm" ];
          truststore = [ ];
        };
      };
    };

    testPdmDarwin311 = {
      expr = pep621.getDependenciesNamesNormalized (
        filterDependenciesByEnviron
          (pep508.mkEnviron mocks.cpythonDarwin311)
          (pep621.parseDependencies {
            pyproject = fixtures."pdm.toml";
          })
      );
      expected = {
        build-systems = [ "pdm-backend" ];
        dependencies = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" ];
        extras = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          keyring = [ "keyring" ];
          pytest = [ "pytest" "pytest-mock" ];
          template = [ "pdm" ];
          truststore = [ "truststore" ];
        };
      };
    };
  };
})
