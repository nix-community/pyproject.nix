{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (python3Packages.hatchling)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      packaging = [ ];
      pathspec = [ ];
      pluggy = [ ];
      trove-classifiers = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
    };

  nativeBuildInputs = [
    pyprojectHook
  ] ++ resolveBuildSystem finalAttrs.passthru.dependencies;
})
