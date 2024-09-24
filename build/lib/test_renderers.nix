{
  pyproject-nix,
  lib,
  pkgs,
}:

let
  inherit (pyproject-nix.build.lib.renderers) mkDerivation;
  inherit (pyproject-nix.lib.project) loadPyproject;

  libFixtures = import ../../lib/fixtures;

  python = pkgs.python312;

  pythonSet = pkgs.callPackage pyproject-nix.build.packages { inherit python; };

in

{
  mkDerivation =
    let
      environ = pyproject-nix.lib.pep508.mkEnviron pkgs.python312;

      renderFixture =
        fixture:
        let
          rendered =
            (mkDerivation {
              project = loadPyproject {
                pyproject = libFixtures.${fixture};
              };
              inherit environ;
            })
              {
                pyprojectHook = null;
                inherit (pythonSet.pythonPkgsHostHost) resolveBuildSystem;
              };
        in
        rendered
        // {
          nativeBuildInputs = map (
            input: if input == null then null else input.pname
          ) rendered.nativeBuildInputs;
        };

    in
    {
      testPandas = {
        expr = renderFixture "pandas.toml";
        expected = {
          meta = {
            description = "Powerful data structures for data analysis, time series, and statistics";
          };
          nativeBuildInputs = [
            null
            "cython"
            "meson"
            "ninja"
            "meson-python"
            "meson"
            "ninja"
            "pyproject-metadata"
            "packaging"
            "tomli"
            "oldest-supported-numpy"
            "numpy"
            "versioneer"
            "tomli"
            "wheel"
          ];
          passthru = {
            dependencies = {
              numpy = [ ];
              python-dateutil = [ ];
              pytz = [ ];
              tzdata = [ ];
            };
            optional-dependencies = {
              all = {
                beautifulsoup4 = [ ];
                bottleneck = [ ];
                brotlipy = [ ];
                fastparquet = [ ];
                fsspec = [ ];
                gcsfs = [ ];
                html5lib = [ ];
                hypothesis = [ ];
                jinja2 = [ ];
                lxml = [ ];
                matplotlib = [ ];
                numba = [ ];
                numexpr = [ ];
                odfpy = [ ];
                openpyxl = [ ];
                pandas-gbq = [ ];
                psycopg2 = [ ];
                pyarrow = [ ];
                pymysql = [ ];
                pyqt5 = [ ];
                pyreadstat = [ ];
                pytest = [ ];
                pytest-asyncio = [ ];
                pytest-xdist = [ ];
                python-snappy = [ ];
                pyxlsb = [ ];
                qtpy = [ ];
                s3fs = [ ];
                scipy = [ ];
                sqlalchemy = [ ];
                tables = [ ];
                tabulate = [ ];
                xarray = [ ];
                xlrd = [ ];
                xlsxwriter = [ ];
                zstandard = [ ];
              };
              aws = {
                s3fs = [ ];
              };
              clipboard = {
                pyqt5 = [ ];
                qtpy = [ ];
              };
              compression = {
                brotlipy = [ ];
                python-snappy = [ ];
                zstandard = [ ];
              };
              computation = {
                scipy = [ ];
                xarray = [ ];
              };
              excel = {
                odfpy = [ ];
                openpyxl = [ ];
                pyxlsb = [ ];
                xlrd = [ ];
                xlsxwriter = [ ];
              };
              feather = {
                pyarrow = [ ];
              };
              fss = {
                fsspec = [ ];
              };
              gcp = {
                gcsfs = [ ];
                pandas-gbq = [ ];
              };
              hdf5 = {
                tables = [ ];
              };
              html = {
                beautifulsoup4 = [ ];
                html5lib = [ ];
                lxml = [ ];
              };
              mysql = {
                pymysql = [ ];
                sqlalchemy = [ ];
              };
              output_formatting = {
                jinja2 = [ ];
                tabulate = [ ];
              };
              parquet = {
                pyarrow = [ ];
              };
              performance = {
                bottleneck = [ ];
                numba = [ ];
                numexpr = [ ];
              };
              plot = {
                matplotlib = [ ];
              };
              postgresql = {
                psycopg2 = [ ];
                sqlalchemy = [ ];
              };
              spss = {
                pyreadstat = [ ];
              };
              sql-other = {
                sqlalchemy = [ ];
              };
              test = {
                hypothesis = [ ];
                pytest = [ ];
                pytest-asyncio = [ ];
                pytest-xdist = [ ];
              };
              xml = {
                lxml = [ ];
              };
            };
          };
          pname = "pandas";
          name = "pandas";
        };
      };

      testPdm = {
        expr = renderFixture "pdm.toml";
        expected = {
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
            null
            "pdm-backend"
          ];
          passthru = {
            dependencies = {
              blinker = [ ];
              cachecontrol = [ "filecache" ];
              certifi = [ ];
              findpython = [ ];
              installer = [ ];
              packaging = [ ];
              platformdirs = [ ];
              pyproject-hooks = [ ];
              python-dotenv = [ ];
              requests-toolbelt = [ ];
              resolvelib = [ ];
              rich = [ ];
              shellingham = [ ];
              tomlkit = [ ];
              unearth = [ ];
              virtualenv = [ ];
            };
            optional-dependencies = {
              all = {
                pdm = [
                  "keyring"
                  "template"
                  "truststore"
                ];
              };
              cookiecutter = {
                cookiecutter = [ ];
              };
              copier = {
                copier = [ ];
              };
              keyring = {
                keyring = [ ];
              };
              pytest = {
                pytest = [ ];
                pytest-mock = [ ];
              };
              template = {
                pdm = [
                  "copier"
                  "cookiecutter"
                ];
              };
              truststore = {
                truststore = [ ];
              };
            };
          };
          pname = "pdm";
          name = "pdm";
        };
      };

      testUv = {
        expr = renderFixture "uv.toml";
        expected = {
          meta = {
            description = "Add your description here";
          };
          nativeBuildInputs = [
            null
            "hatchling"
            "packaging"
            "pathspec"
            "pluggy"
            "trove-classifiers"
          ];
          passthru = {
            dependencies = { };
            optional-dependencies = { };
          };
          pname = "uv-fixture";
          version = "0.1.0";
        };
      };
    };
}
