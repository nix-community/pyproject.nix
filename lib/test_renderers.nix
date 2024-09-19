{
  lib,
  project,
  fixtures,
  renderers,
  mocks,
  ...
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
  clearDrvInputs =
    attrs:
    attrs
    // {
      dependencies = map (drv: drv.pname) attrs.dependencies;
      build-system = map (drv: drv.pname) attrs.build-system;
      optional-dependencies = lib.mapAttrs (
        _group: deps: map (drv: drv.pname) deps
      ) attrs.optional-dependencies;
    }
    // optionalAttrs (attrs ? checkInputs) { checkInputs = map (drv: drv.pname) attrs.checkInputs; };

in
rec {
  # withPackages can't be easily tested by mocks, dummy out.
  # Tested by integration tests.
  withPackages = {
    testDummy = {
      expr = null;
      expected = null;
    };
  };

  mkPythonEditablePackage = {
    testPdm = {
      expr = clearDrvInputs (
        renderers.mkPythonEditablePackage {
          root = "/path/to/my_root";
          project = projects.pdm;
          python = mocks.cpythonLinux38;
        }
      );
      expected = {
        inherit (buildPythonPackage.testPdm.expected)
          dependencies
          optional-dependencies
          build-system
          meta
          pname
          ;
        root = "/path/to/my_root";
        scripts = {
          pdm = "pdm.core:main";
        };
      };
    };
  };

  # Implicitly tested by buildPythonPackage test
  meta = {
    testDummy = {
      expr = null;
      expected = null;
    };
  };

  buildPythonPackage = {
    testPdm = {
      expr = clearDrvInputs (
        renderers.buildPythonPackage {
          project = projects.pdm;
          python = mocks.cpythonLinux38;
        }
      );
      expected = {
        disabled = false;
        pyproject = true;
        meta = {
          description = "A modern Python package and dependency manager supporting the latest PEP standards";
          license = lib.licenses.mit;
          mainProgram = "pdm";
        };
        build-system = [ "pdm-backend" ];
        pname = "pdm";
        optional-dependencies = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          doc = [
            "mkdocs"
            "mkdocs-material"
            "mkdocstrings"
            "mike"
            "setuptools"
            "markdown-exec"
            "mkdocs-redirects"
          ];
          keyring = [ "keyring" ];
          pytest = [
            "pytest"
            "pytest-mock"
          ];
          template = [ "pdm" ];
          test = [
            "pdm"
            "pytest-cov"
            "pytest-xdist"
            "pytest-rerunfailures"
            "pytest-httpserver"
          ];
          tox = [
            "tox"
            "tox-pdm"
          ];
          truststore = [ "truststore" ];
          workflow = [
            "pdm-pep517"
            "parver"
            "towncrier"
            "pycomplete"
          ];
        };
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
      };
    };

    # Test that a license not in the spdix table is properly passed through verbatim
    testNonSpdxLicense =
      let
        fixture = lib.recursiveUpdate fixtures."pdm.toml" { project.license.text = "Proprietary"; };
        attrs = renderers.buildPythonPackage {
          project = loadPyproject { pyproject = fixture; };
          python = mocks.cpythonLinux38;
        };
      in
      {
        expr = attrs.meta.license;
        expected = "Proprietary";
      };

    testPdmWithMaps = {
      expr = clearDrvInputs (
        renderers.buildPythonPackage {
          project = projects.pdm;
          python = mocks.cpythonLinux38;
          extras = [ "tox" ];
          extrasAttrMappings = {
            tox = "checkInputs";
          };
        }
      );
      expected = {
        disabled = false;
        checkInputs = [
          "tox"
          "tox-pdm"
        ];
        pyproject = true;
        meta = {
          description = "A modern Python package and dependency manager supporting the latest PEP standards";
          license = lib.licenses.mit;
          mainProgram = "pdm";
        };
        build-system = [ "pdm-backend" ];
        pname = "pdm";
        optional-dependencies = {
          all = [ "pdm" ];
          cookiecutter = [ "cookiecutter" ];
          copier = [ "copier" ];
          doc = [
            "mkdocs"
            "mkdocs-material"
            "mkdocstrings"
            "mike"
            "setuptools"
            "markdown-exec"
            "mkdocs-redirects"
          ];
          keyring = [ "keyring" ];
          pytest = [
            "pytest"
            "pytest-mock"
          ];
          template = [ "pdm" ];
          test = [
            "pdm"
            "pytest-cov"
            "pytest-xdist"
            "pytest-rerunfailures"
            "pytest-httpserver"
          ];
          tox = [
            "tox"
            "tox-pdm"
          ];
          truststore = [ "truststore" ];
          workflow = [
            "pdm-pep517"
            "parver"
            "towncrier"
            "pycomplete"
          ];
        };
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
          "tox"
          "tox-pdm"
        ];
      };
    };
  };
}
