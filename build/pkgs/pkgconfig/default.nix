{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pkgconfig)
    pname
    version
    src
    meta
    postPatch
    ;

  inherit (python3Packages.pkgconfig)
    setupHooks
    wrapperName
    suffixSalt
    targetPrefix
    baseBinName
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      poetry-core = [ ];
    };
}
