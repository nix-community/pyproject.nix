{ project
, fixtures
, renderers
, mocks
, ...
}:
let
  inherit (project) loadPyproject loadPoetryPyproject;

  # Get python packages from a set
  getPkgs = set: pnames: map (pname: set.pkgs.${pname}) pnames;

in
{
  loadPyproject = {
    testPdm = {
      expr =
        let
          project = loadPyproject { pyproject = fixtures."pdm.toml"; };
        in
        renderers.buildPythonPackage {
          inherit project;
          python = mocks.cpythonLinux38;
        };
      expected = {
        format = "pyproject";
        meta = {
          description = "A modern Python package and dependency manager supporting the latest PEP standards";
          license = {
            deprecated = false;
            free = true;
            fullName = "MIT License";
            redistributable = true;
            shortName = "mit";
            spdxId = "MIT";
            url = "https://spdx.org/licenses/MIT.html";
          };
          mainProgram = "pdm";
        };
        nativeBuildInputs = getPkgs mocks.cpythonLinux38 [
          "pdm-backend"
        ];
        pname = "pdm";
        propagatedBuildInputs = getPkgs mocks.cpythonLinux38 [
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
      };
    };

    testPandas = {
      expr =
        let
          project = loadPyproject { pyproject = fixtures."pandas.toml"; };
        in
        renderers.buildPythonPackage {
          inherit project;
          python = mocks.cpythonLinux38;
        };
      expected = {
        format = "pyproject";
        meta = { description = "Powerful data structures for data analysis, time series, and statistics"; };
        nativeBuildInputs = getPkgs mocks.cpythonLinux38 [
          "meson-python"
          "meson"
          "wheel"
          "cython"
          "oldest-supported-numpy"
          "versioneer"
        ];
        pname = "pandas";
        propagatedBuildInputs = getPkgs mocks.cpythonLinux38 [
          "numpy"
          "python-dateutil"
          "pytz"
          "tzdata"
        ];
      };
    };
  };

  loadPoetryPyproject = {
    testProjectRenderBuildPythonPackage = {
      expr =
        let
          project = loadPoetryPyproject { pyproject = fixtures."poetry.toml"; };
        in
        renderers.buildPythonPackage {
          inherit project;
          extras = [ "dev" ];
          python = mocks.cpythonLinux38;
        };
      expected = {
        format = "pyproject";
        meta = {
          description = "Python dependency management and packaging made easy.";
          license = {
            deprecated = false;
            free = true;
            fullName = "MIT License";
            redistributable = true;
            shortName = "mit";
            spdxId = "MIT";
            url = "https://spdx.org/licenses/MIT.html";
          };
        };
        nativeBuildInputs = getPkgs mocks.cpythonLinux38 [
          "poetry-core"
        ];
        pname = "poetry";
        propagatedBuildInputs = getPkgs mocks.cpythonLinux38 [
          "build"
          "cachecontrol"
          "cleo"
          "crashtest"
          "dulwich"
          "filelock"
          "html5lib"
          "importlib-metadata"
          "installer"
          "jsonschema"
          "keyring"
          "lockfile"
          "packaging"
          "pexpect"
          "pkginfo"
          "platformdirs"
          "poetry-core"
          "poetry-plugin-export"
          "pyproject-hooks"
          "python3"
          "requests"
          "requests-toolbelt"
          "shellingham"
          "tomli"
          "tomlkit"
          "trove-classifiers"
          "urllib3"
          "virtualenv"
          "pre-commit"
        ];
        version = "1.4.2";
      };
    };
  };

  loadRequirementsTxt = {
    testRecursive = {
      expr = project.loadRequirementsTxt {
        requirements = ./fixtures/requirements-recursive.txt;
      };
      expected = {
        build-systems = [ ];
        dependencies = {
          build-systems = [ ];
          dependencies = [
            {
              conditions = [
                {
                  op = "==";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 10 1 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pillow";
              url = null;
            }
            {
              conditions = [
                {
                  op = "==";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 2 31 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "requests";
              url = null;
            }
          ];
          extras = { };
        };
        pyproject = null;
      };
    };
  };
}
