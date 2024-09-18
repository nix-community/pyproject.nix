{
  stdenv,
  pyprojectHook,
  resolveBuildSystem,
  pkgs,
}:
stdenv.mkDerivation {
  inherit (pkgs.meson)
    pname
    version
    src
    meta
    patches
    setupHook
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
      wheel = [ ];
    };
}
