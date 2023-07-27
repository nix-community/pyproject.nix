{ lib
, project
, fixtures
, renderers
, mocks
, ...
}:
let
  inherit (project) loadPyproject;
  inherit (lib) optionalAttrs;

  projects = {
    pdm = loadPyproject {
      pyproject = fixtures."pdm.toml";
      extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
    };
    pandas = loadPyproject { pyproject = fixtures."pandas.toml"; };
  };

  # Clear drv inputs from stuff like version and just return the name string
  # so our tests don't start failing randomly just because we upgrade and nixpkgs moved
  clearDrvInputs = attrs: attrs // {
    propagatedBuildInputs = map (drv: drv.pname) attrs.propagatedBuildInputs;
    nativeBuildInputs = map (drv: drv.pname) attrs.nativeBuildInputs;
  } // optionalAttrs (attrs ? checkInputs) {
    checkInputs = map (drv: drv.pname) attrs.checkInputs;
  };

in
{
  withPackages = {
    testPdm = {
      expr =
        map (drv: drv.pname) (
          let
            rendered = renderers.withPackages {
              project = projects.pdm;
              python = mocks.cpythonLinux38;
            };
          in
          rendered mocks.cpythonLinux38.pkgs
        );
      expected = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" "pdm-backend" ];
    };
  };

  buildPythonPackage = {
    testPdm = {
      expr = clearDrvInputs (renderers.buildPythonPackage {
        project = projects.pdm;
        python = mocks.cpythonLinux38;
      });
      expected = {
        format = "pyproject";
        meta = {
          description = "A modern Python package and dependency manager supporting the latest PEP standards";
          license = lib.licenses.mit;
          mainProgram = "pdm";
        };
        nativeBuildInputs = [ "pdm-backend" ];
        pname = "pdm";
        propagatedBuildInputs = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
      };
    };

    testPdmWithMaps = {
      expr = clearDrvInputs (renderers.buildPythonPackage {
        project = projects.pdm;
        python = mocks.cpythonLinux38;
        extras = [ "tox" ];
        extrasAttrMappings = {
          tox = "checkInputs";
        };
      });
      expected = {
        checkInputs = [ "tox" "tox-pdm" ];
        format = "pyproject";
        meta = {
          description = "A modern Python package and dependency manager supporting the latest PEP standards";
          license = lib.licenses.mit;
          mainProgram = "pdm";
        };
        nativeBuildInputs = [ "pdm-backend" ];
        pname = "pdm";
        propagatedBuildInputs = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
      };
    };
  };
}
