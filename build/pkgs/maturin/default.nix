{
  stdenv,
  pkgs,
  rustPlatform,
  cargo,
  rustc,
  pyprojectHook,
  resolveBuildSystem,
}:

stdenv.mkDerivation {
  inherit (pkgs.maturin)
    pname
    version
    cargoDeps
    src
    meta
    ;

  nativeBuildInputs =
    [
      rustPlatform.cargoSetupHook
      pyprojectHook
      cargo
      rustc
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
      wheel = [ ];
      tomli = [ ];
      setuptools-rust = [ ];
    };
}
