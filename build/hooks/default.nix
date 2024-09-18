{
  callPackage,
  makeSetupHook,
  python,
  pkgs,
  lib,
  resolveBuildSystem,
  stdenv,
  hooks,
  pythonPackagesBuildHost,
}:
let
  inherit (python) pythonOnBuildForHost isPy3k;
  inherit (pkgs) buildPackages;
  pythonInterpreter = pythonOnBuildForHost.interpreter;
  pythonSitePackages = python.sitePackages;

in
{
  # Build hook used to build PEP-621/setuptools projects
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

  # Build hook used to build PEP-621/setuptools projects
  pyprojectBuildHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-build-hook";
      substitutions = {
        inherit (pythonPackagesBuildHost) build;
        inherit pythonInterpreter;
      };
      propagatedBuildInputs = resolveBuildSystem {
        build = [ ];
      };
    } ./pyproject-build-hook.sh
  ) { };

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

  pyprojectPypaInstallHook = callPackage (
    { pythonPackagesBuildHost }:
    makeSetupHook {
      name = "pyproject-pypa-install-hook";
      substitutions = {
        inherit (pythonPackagesBuildHost) installer;
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pyproject-pypa-install-hook.sh
  ) { };

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

  pyprojectOutputSetupHook = callPackage (
    _:
    makeSetupHook {
      name = "pyproject-output-setup-hook";
      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pyproject-output-setup-hook.sh
  ) { };

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

  # Meta hook aggregating the default pyproject.toml/setup.py install behaviour and adds Python
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
}
