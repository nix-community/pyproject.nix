{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation {
  inherit (python3Packages.poetry-core)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    pyprojectHook
  ];
}
