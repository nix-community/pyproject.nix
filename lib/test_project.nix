{ project
, fixtures
, renderers
, mocks
, lib
, pypa
, ...
}:
let
  inherit (project) loadPyproject loadPoetryPyproject loadPDMPyproject loadPyprojectDynamic;

  # Get python packages from a set
  getPkgs = set: pnames: map (pname: set.pkgs.${pypa.normalizePackageName pname}) pnames;

in
lib.fix (self: {

  loadPyproject = {
    testPandasMissingExtrasAttrPaths = {
      expr =
        let
          project = loadPyproject {
            pyproject = fixtures."pandas.toml";
            extrasAttrPaths = [ "noway" ];
          };
        in
        renderers.buildPythonPackage {
          inherit project;
          python = mocks.cpythonLinux38;
        };
      inherit (self.loadPyproject.testPandas) expected;
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
      expected =
        let
          getPkgs' = getPkgs mocks.cpythonLinux38;
        in
        {
          format = "pyproject";
          disabled = true;
          meta = { description = "Powerful data structures for data analysis, time series, and statistics"; };
          passthru.optional-dependencies = lib.mapAttrs (_: getPkgs') {
            all = [ "beautifulsoup4" "bottleneck" "brotlipy" "fastparquet" "fsspec" "gcsfs" "html5lib" "hypothesis" "Jinja2" "lxml" "matplotlib" "numba" "numexpr" "odfpy" "openpyxl" "pandas-gbq" "psycopg2" "pyarrow" "PyMySQL" "PyQt5" "pyreadstat" "pytest" "pytest-xdist" "pytest-asyncio" "python-snappy" "pyxlsb" "QtPy" "scipy" "s3fs" "SQLAlchemy" "tables" "tabulate" "xarray" "xlrd" "xlsxwriter" "zstandard" ];
            aws = [ "s3fs" ];
            clipboard = [ "PyQt5" "QtPy" ];
            compression = [ "brotlipy" "python-snappy" "zstandard" ];
            computation = [ "scipy" "xarray" ];
            excel = [ "odfpy" "openpyxl" "pyxlsb" "xlrd" "xlsxwriter" ];
            feather = [ "pyarrow" ];
            fss = [ "fsspec" ];
            gcp = [ "gcsfs" "pandas-gbq" ];
            hdf5 = [ "tables" ];
            html = [ "beautifulsoup4" "html5lib" "lxml" ];
            mysql = [ "SQLAlchemy" "PyMySQL" ];
            output_formatting = [ "Jinja2" "tabulate" ];
            parquet = [ "pyarrow" ];
            performance = [ "bottleneck" "numba" "numexpr" ];
            plot = [ "matplotlib" ];
            postgresql = [ "SQLAlchemy" "psycopg2" ];
            spss = [ "pyreadstat" ];
            sql-other = [ "SQLAlchemy" ];
            test = [ "hypothesis" "pytest" "pytest-xdist" "pytest-asyncio" ];
            xml = [ "lxml" ];
          };
          nativeBuildInputs = getPkgs' [
            "meson-python"
            "meson"
            "wheel"
            "cython"
            "oldest-supported-numpy"
            "versioneer"
          ];
          pname = "pandas";
          propagatedBuildInputs = getPkgs' [
            "numpy"
            "python-dateutil"
            "pytz"
            "tzdata"
          ];
        };
    };
  };

  loadPDMPyproject = {
    testPdm = {
      expr =
        let
          project = loadPDMPyproject {
            pyproject = fixtures."pdm.toml";
            projectRoot = ./fixtures;
          };

          attrs = renderers.buildPythonPackage {
            inherit project;
            python = mocks.cpythonLinux38;
          };

        in
        attrs // {
          # Assert shape for src, not exact equality
          src = lib.isStorePath "${attrs.src}";
        };

      expected =
        let
          getPkgs' = getPkgs mocks.cpythonLinux38;
        in
        {
          disabled = false;
          src = true;
          format = "pyproject";
          passthru.optional-dependencies = lib.mapAttrs (_: getPkgs') {
            all = [ "pdm" ];
            cookiecutter = [ "cookiecutter" ];
            copier = [ "copier" ];
            doc = [ "mkdocs" "mkdocs-material" "mkdocstrings" "mike" "setuptools" "markdown-exec" "mkdocs-redirects" ];
            keyring = [ "keyring" ];
            pytest = [ "pytest" "pytest-mock" ];
            template = [ "pdm" ];
            test = [ "pdm" "pytest-cov" "pytest-xdist" "pytest-rerunfailures" "pytest-httpserver" ];
            tox = [ "tox" "tox-pdm" ];
            truststore = [ "truststore" ];
            workflow = [ "pdm-pep517" "parver" "towncrier" "pycomplete" ];
          };
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
      expected =
        let
          getPkgs' = getPkgs mocks.cpythonLinux38;
        in
        {
          format = "pyproject";
          passthru.optional-dependencies = lib.mapAttrs (_: getPkgs') {
            dev = [ "pre-commit" ];
            github-actions = [ "pytest-github-actions-annotate-failures" ];
            test = [ "cachy" "deepdiff" "deepdiff" "httpretty" "pytest" "pytest-cov" "pytest-mock" "pytest-randomly" "pytest-xdist" "zipp" ];
            typing = [ "mypy" "types-html5lib" "types-jsonschema" "types-requests" "typing-extensions" ];
          };
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
            mainProgram = "poetry";
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

  loadPyprojectDynamic = {
    testPoetry = {
      expr =
        let
          project = loadPyprojectDynamic { pyproject = fixtures."poetry.toml"; };
        in
        renderers.buildPythonPackage {
          inherit project;
          extras = [ "dev" ];
          python = mocks.cpythonLinux38;
        };
      inherit (self.loadPoetryPyproject.testProjectRenderBuildPythonPackage) expected;
    };

    testPep621 = {
      expr =
        (loadPyprojectDynamic { pyproject = fixtures."pandas.toml"; }).renderers.buildPythonPackage {
          inherit project;
          python = mocks.cpythonLinux38;
        };
      inherit (self.loadPyproject.testPandas) expected;
    };

    testError = {
      expr = loadPyprojectDynamic {
        pyproject = { };
      };
      expectedError.type = "ThrownError";
      expectedError.msg = "Project is neither Poetry nor PEP-621";
    };
  };

  loadRequirementsTxt = {
    testRecursive = {
      expr =
        let
          self = project.loadRequirementsTxt {
            requirements = ./fixtures/requirements-recursive.txt;
          };
        in
        self // {
          renderers = lib.attrNames self.renderers;
          validators = lib.attrNames self.validators;
        };
      expected = {
        renderers = [ "buildPythonPackage" "withPackages" ];
        requires-python = null;
        validators = [ "validateVersionConstraints" ];
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
        projectRoot = null;
      };
    };
  };
})
