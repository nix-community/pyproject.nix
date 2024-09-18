{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.whool)
    pname
    version
    src
    meta
    setupHook
    ;

  passthru.dependencies =
    {
      manifestoo-core = [ ];
      wheel = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
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
