{ lib, pep621, ... }:

let
  inherit (builtins) mapAttrs;
  inherit (lib) importTOML;
  inherit (pep621) parseDependencies parseRequiresPython getDependenciesNamesNormalized;

  fixtures = mapAttrs (name: _: importTOML ./fixtures/${name}) (builtins.readDir ./fixtures);
  expected = mapAttrs (name: _: import ./expected/${name}) (builtins.readDir ./expected);
in
lib.fix (self: {
  parseDependencies = {
    testPandas = {
      expr = parseDependencies {
        pyproject = fixtures."pandas.toml";
      };
      expected = expected."parsedependencies-pandas.nix";
    };

    testPdm = {
      expr = parseDependencies {
        pyproject = fixtures."pdm.toml";
      };
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
            release = [ 3 9 ];
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
            release = [ 3 7 ];
          };
        }
      ];
    };
  };

  getDependenciesNamesNormalized = {
    testPandas = {
      expr = getDependenciesNamesNormalized self.parseDependencies.testPandas.expr;
      expected = {
        dependencies = [ "numpy" "numpy" "python-dateutil" "pytz" "tzdata" ];
        extras = {
          all = [ "beautifulsoup4" "bottleneck" "brotlipy" "fastparquet" "fsspec" "gcsfs" "html5lib" "hypothesis" "jinja2" "lxml" "matplotlib" "numba" "numexpr" "odfpy" "openpyxl" "pandas-gbq" "psycopg2" "pyarrow" "pymysql" "pyqt5" "pyreadstat" "pytest" "pytest-xdist" "pytest-asyncio" "python-snappy" "pyxlsb" "qtpy" "scipy" "s3fs" "sqlalchemy" "tables" "tabulate" "xarray" "xlrd" "xlsxwriter" "zstandard" ];
          aws = [ "s3fs" ];
          clipboard = [ "pyqt5" "qtpy" ];
          compression = [ "brotlipy" "python-snappy" "zstandard" ];
          computation = [ "scipy" "xarray" ];
          excel = [ "odfpy" "openpyxl" "pyxlsb" "xlrd" "xlsxwriter" ];
          feather = [ "pyarrow" ];
          fss = [ "fsspec" ];
          gcp = [ "gcsfs" "pandas-gbq" ];
          hdf5 = [ "tables" ];
          html = [ "beautifulsoup4" "html5lib" "lxml" ];
          mysql = [ "sqlalchemy" "pymysql" ];
          output_formatting = [ "jinja2" "tabulate" ];
          parquet = [ "pyarrow" ];
          performance = [ "bottleneck" "numba" "numexpr" ];
          plot = [ "matplotlib" ];
          postgresql = [ "sqlalchemy" "psycopg2" ];
          spss = [ "pyreadstat" ];
          sql-other = [ "sqlalchemy" ];
          test = [ "hypothesis" "pytest" "pytest-xdist" "pytest-asyncio" ];
          xml = [ "lxml" ];
        };
      };
    };

    testPdm = {
      expr = getDependenciesNamesNormalized self.parseDependencies.testPdm.expr;
      expected = {
        dependencies = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
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
