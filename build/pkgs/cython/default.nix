{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (python3Packages.cython)
    pname
    version
    src
    meta
    setupHook
    ;

  nativeBuildInputs =
    [
      pyprojectHook
      pkg-config
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
