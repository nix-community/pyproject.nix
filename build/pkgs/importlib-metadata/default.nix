{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.importlib-metadata)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      toml = [ ];
      zipp = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.8") {
      typing-extensions = [ ];
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
