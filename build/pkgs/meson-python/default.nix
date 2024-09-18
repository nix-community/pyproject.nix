{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (python3Packages.meson-python)
    pname
    version
    src
    meta
    setupHooks
    ;

  passthru.dependencies =
    {
      meson = [ ];
      ninja = [ ];
      pyproject-metadata = [ ];
      tomli = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.10") {
      typing-extensions = [ ];
    };

  nativeBuildInputs = [
    pyprojectHook
  ] ++ resolveBuildSystem finalAttrs.passthru.dependencies;
})
