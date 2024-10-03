{
  callPackage,
  makeSetupHook,
  python,
  pkgs,
  lib,
  resolveBuildSystem,
  stdenv,
  hooks,
  pythonPkgsBuildHost,
}:
let
  inherit (python) pythonOnBuildForHost isPy3k;
  inherit (pkgs) buildPackages;
  pythonInterpreter = pythonOnBuildForHost.interpreter;
  pythonSitePackages = python.sitePackages;

in
{
  /*
    Undo any `$PYTHONPATH` changes done by nixpkgs Python infrastructure dependency propagation.

    Used internally by `pyprojectHook`.
  */
  pyprojectConfigureHook = callPackage (
    { python }:
    makeSetupHook {
      name = "pyproject-configure-hook";
      substitutions = {
        inherit pythonInterpreter;
        pythonPath = lib.concatStringsSep ":" (
          lib.optional (
            stdenv.buildPlatform != stdenv.hostPlatform
          ) "${python.pythonOnBuildForHost}/${python.sitePackages}"
          ++ [
            "${python}/${python.sitePackages}"
          ]
        );
      };
    } ./pyproject-configure-hook.sh
  ) { };

  /*
    Build a pyproject.toml/setuptools project.

    Used internally by `pyprojectHook`.
  */
  pyprojectBuildHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-build-hook";
      substitutions = {
        inherit (pythonPkgsBuildHost) build;
        inherit pythonInterpreter;
      };
      propagatedBuildInputs = resolveBuildSystem {
        build = [ ];
      };
    } ./pyproject-build-hook.sh
  ) { };

  /*
    Symlink prebuilt wheel sources.

    Used internally by `pyprojectWheelHook`.
  */
  pyprojectWheelDistHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-wheel-dist-hook";
    } ./pyproject-wheel-dist-hook.sh
  ) { };

  /*
    Install built projects from dist/*.whl.

    Used internally by `pyprojectHook`.
  */
  pyprojectInstallHook =
    callPackage
      (
        { uv }:
        makeSetupHook {
          name = "pyproject-install-hook";
          substitutions = {
            inherit pythonInterpreter uv;
          };
        } ./pyproject-install-hook.sh
      )
      {
        inherit (buildPackages) uv;
      };

  /*
    Install hook using pypa/installer.

    Used instead of `pyprojectInstallHook` for cross compilation support.
  */
  pyprojectPypaInstallHook = callPackage (
    { pythonPkgsBuildHost }:
    makeSetupHook {
      name = "pyproject-pypa-install-hook";
      substitutions = {
        inherit (pythonPkgsBuildHost) installer;
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pyproject-pypa-install-hook.sh
  ) { };

  /*
    Clean up any shipped bytecode in package output and recompile.

    Used internally by `pyprojectHook`.
  */
  pyprojectBytecodeHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-bytecode-hook";
      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
        compileArgs = lib.concatStringsSep " " (
          [
            "-q"
            "-f"
            "-i -"
          ]
          ++ lib.optionals isPy3k [ "-j $NIX_BUILD_CORES" ]
        );
        bytecodeName = if isPy3k then "__pycache__" else "*.pyc";
      };
    } ./pyproject-bytecode-hook.sh
  ) { };

  /*
    Create `pyproject.nix` setup hook in package output.

    Used internally by `pyprojectHook`.
  */
  pyprojectOutputSetupHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-output-setup-hook";
      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pyproject-output-setup-hook.sh
  ) { };

  /*
    Create a virtual environment from buildInputs

    Used internally by `mkVirtualEnv`.
  */
  pyprojectMakeVenvHook = callPackage (
    { python }:
    makeSetupHook {
      name = "pyproject-make-venv-hook";
      substitutions = {
        inherit pythonInterpreter python;
        makeVenvScript = ./make-venv.py;
      };
    } ./pyproject-make-venv-hook.sh
  ) { };

  /*
    Meta hook aggregating the default pyproject.toml/setup.py install behaviour and adds Python.

    This is the default choice for both pyproject.toml & setuptools projects.
  */
  #
  pyprojectHook =
    callPackage
      (
        {
          pyprojectConfigureHook,
          pyprojectBuildHook,
          pyprojectInstallHook,
          pyprojectOutputSetupHook,
          python,
        }:
        makeSetupHook {
          name = "pyproject-hook";
          propagatedBuildInputs = [
            python
            pyprojectConfigureHook
            pyprojectBuildHook
            pyprojectInstallHook
            pyprojectOutputSetupHook
          ];
        } ./meta-hook.sh
      )
      (
        {
          python = pythonOnBuildForHost;
        }
        // (lib.optionalAttrs (stdenv.buildPlatform != stdenv.hostPlatform) {
          # Uv is not yet compatible with cross installs, or at least I can't figure out the magic incantation.
          # We can use installer for cross, and still use uv for native.
          pyprojectInstallHook = hooks.pyprojectPypaInstallHook;
        })
      );

  /*
    Hook used to build prebuilt wheels.

    Use instead of pyprojectHook.
  */
  pyprojectWheelHook = hooks.pyprojectHook.override {
    pyprojectBuildHook = hooks.pyprojectWheelDistHook;
  };
}
