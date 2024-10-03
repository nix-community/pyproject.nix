{
  stdenv,
  pyprojectHook,
  resolveBuildSystem,
  python3Packages,
  gfortran,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (python3Packages.numpy)
    pname
    version
    src
    meta
    patches
    postPatch
    preConfigure
    postConfigure
    preBuild
    buildInputs
    enableParallelBuilding
    passthru
    ;

  nativeBuildInputs =
    [
      pyprojectHook
      gfortran
      pkg-config
    ]
    ++ resolveBuildSystem {
      meson-python = [ ];
      cython = [ ];
    };
}
