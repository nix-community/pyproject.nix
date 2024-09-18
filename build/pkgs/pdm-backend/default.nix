{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (python3Packages.pdm-backend)
    pname
    version
    src
    meta
    setupHook
    ;

  env = {
    PDM_BUILD_SCM_VERSION = finalAttrs.version;
  };

  passthru.dependencies = lib.optionalAttrs (python.pythonOlder "3.10") {
    importlib-metadata = [ ];
  };

  nativeBuildInputs = [
    pyprojectHook
  ];
})
