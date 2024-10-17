{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.manifestoo-core)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    lib.optionalAttrs (python.pythonOlder "3.7") {
      importlib-resources = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.8") {
      typing-extensions = [ ];
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
