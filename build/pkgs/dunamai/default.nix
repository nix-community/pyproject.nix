{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.dunamai)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      packaging = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.8") {
      importlib-metadata = [ ];
    };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      poetry-core = [ ];
    };
}
