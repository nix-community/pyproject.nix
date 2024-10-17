{
  stdenv,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
  pkg-config,
  libffi,
}:
stdenv.mkDerivation {
  inherit (python3Packages.cffi)
    pname
    version
    src
    meta
    patches
    postPatch
    ;

  env = {
    inherit (python3Packages.cffi) NIX_CFLAGS_COMPILE;
  };

  buildInputs = [ libffi ];

  nativeBuildInputs =
    [
      pyprojectHook
      pkg-config
      python
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
