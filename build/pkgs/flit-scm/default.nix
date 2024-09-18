{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (python3Packages.flit-scm)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      flit-core = [ ];
      setuptools-scm = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
    };

  nativeBuildInputs = [
    pyprojectHook
  ] ++ resolveBuildSystem finalAttrs.passthru.dependencies;
})
