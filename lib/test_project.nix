{ project
, fixtures
, renderers
, mocks
, ...
}:
let
  inherit (project) loadPyproject loadPoetryPyproject;
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
        nativeBuildInputs = [
          {
            pname = "pdm-backend";
            version = "2.1.1";
          }
        ];
        pname = "pdm";
        propagatedBuildInputs = [
          {
            pname = "blinker";
            version = "1.5";
          }
          {
            pname = "certifi";
            version = "2022.12.07";
          }
          {
            pname = "packaging";
            version = "23.0";
          }
          {
            pname = "platformdirs";
            version = "3.5.1";
          }
          {
            pname = "rich";
            version = "13.3.5";
          }
          {
            pname = "virtualenv";
            version = "20.19.0";
          }
          {
            pname = "pyproject-hooks";
            version = "1.0.0";
          }
          {
            pname = "requests-toolbelt";
            version = "0.10.1";
          }
          {
            pname = "unearth";
            version = "0.9.1";
          }
          {
            pname = "findpython";
            version = "0.3.0";
          }
          {
            pname = "tomlkit";
            version = "0.11.6";
          }
          {
            pname = "shellingham";
            version = "1.5.1";
          }
          {
            pname = "python-dotenv";
            version = "1.0.0";
          }
          {
            pname = "resolvelib";
            version = "0.5.5";
          }
          {
            pname = "installer";
            version = "0.7.0";
          }
          {
            pname = "cachecontrol";
            version = "0.13.1";
          }
          {
            pname = "tomli";
            version = "2.0.1";
          }
          {
            pname = "importlib-resources";
            version = "5.12.0";
          }
          {
            pname = "importlib-metadata";
            version = "6.0.0";
          }
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
        nativeBuildInputs = [
          {
            pname = "meson-python";
            version = "0.12.1";
          }
          {
            pname = "meson";
            version = "1.1.1";
          }
          {
            pname = "wheel";
            version = "0.38.4";
          }
          {
            pname = "cython";
            version = "0.29.34";
          }
          {
            pname = "oldest-supported-numpy";
            version = "1.0.0";
          }
          {
            pname = "versioneer";
            version = "0.28";
          }
        ];
        pname = "pandas";
        propagatedBuildInputs = [
          {
            pname = "numpy";
            version = "1.24.2";
          }
          {
            pname = "python-dateutil";
            version = "2.8.2";
          }
          {
            pname = "pytz";
            version = "2023.3";
          }
          {
            pname = "tzdata";
            version = "2022.7";
          }
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
        nativeBuildInputs = [
          {
            pname = "poetry-core";
            version = "1.5.1";
          }
        ];
        pname = "poetry";
        propagatedBuildInputs = [
          {
            pname = "build";
            version = "0.10.0";
          }
          {
            pname = "cachecontrol";
            version = "0.13.1";
          }
          {
            pname = "cleo";
            version = "2.0.1";
          }
          {
            pname = "crashtest";
            version = "0.4.1";
          }
          {
            pname = "dulwich";
            version = "0.21.5";
          }
          {
            pname = "filelock";
            version = "3.12.0";
          }
          {
            pname = "html5lib";
            version = "1.1";
          }
          {
            pname = "importlib-metadata";
            version = "6.0.0";
          }
          {
            pname = "installer";
            version = "0.7.0";
          }
          {
            pname = "jsonschema";
            version = "4.17.3";
          }
          {
            pname = "keyring";
            version = "23.13.1";
          }
          {
            pname = "lockfile";
            version = "0.12.2";
          }
          {
            pname = "packaging";
            version = "23.0";
          }
          {
            pname = "pexpect";
            version = "4.8.0";
          }
          {
            pname = "pkginfo";
            version = "1.9.6";
          }
          {
            pname = "platformdirs";
            version = "3.5.1";
          }
          {
            pname = "poetry-core";
            version = "1.5.1";
          }
          {
            pname = "poetry-plugin-export";
            version = "1.4.0";
          }
          {
            pname = "pyproject-hooks";
            version = "1.0.0";
          }
          {
            pname = "python3";
            version = "3.10.12";
          }
          {
            pname = "requests";
            version = "2.31.0";
          }
          {
            pname = "requests-toolbelt";
            version = "0.10.1";
          }
          {
            pname = "shellingham";
            version = "1.5.1";
          }
          {
            pname = "tomli";
            version = "2.0.1";
          }
          {
            pname = "tomlkit";
            version = "0.11.6";
          }
          {
            pname = "trove-classifiers";
            version = "2023.5.24";
          }
          {
            pname = "urllib3";
            version = "1.26.14";
          }
          {
            pname = "virtualenv";
            version = "20.19.0";
          }
          {
            pname = "pre-commit";
            version = "3.3.3";
          }
        ];
        version = "1.4.2";
      };
    };
  };
}
