{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.setuptools-rust)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      semantic-version = [ ];
      setuptools = [ ];
      typing-extensions = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
    };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
      setuptools-scm = [ ];
    };
}
