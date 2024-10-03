{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.scikit-build-core)
    pname
    version
    src
    meta
    patches
    ;

  passthru.dependencies =
    {
      packaging = [ ];
      pathspec = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      exceptiongroup = [ ];
      tomli = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.9") {
      importlib-resources = [ ];
      typing-extensions = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.8") {
      importlib-metadata = [ ];
    };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
      hatch-vcs = [ ];
    };
}
