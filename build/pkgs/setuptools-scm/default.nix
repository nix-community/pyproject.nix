{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.setuptools-scm)
    pname
    version
    src
    meta
    setupHook
    ;

  passthru = {
    dependencies =
      {
        packaging = [ ];
        setuptools = [ ];
      }
      // lib.optionalAttrs (python.pythonOlder "3.11") {
        tomli = [ ];
      }
      // lib.optionalAttrs (python.pythonOlder "3.10") {
        typing-extensions = [ ];
      };

    optional-dependencies = {
      toml = {
        tomli = [ ];
      };
      rich = {
        rich = [ ];
      };
    };
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem (
      {
        setuptools = [ ];
      }
      // lib.optionalAttrs (python.pythonOlder "3.11") {
        tomli = [ ];
      }
    );
}
