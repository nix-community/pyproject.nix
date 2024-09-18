{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.cmake)
    pname
    version
    src
    meta
    postUnpack
    setupHooks
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
