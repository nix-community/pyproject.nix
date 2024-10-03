{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pdm-pep517)
    pname
    version
    src
    meta
    ;
  nativeBuildInputs = [
    pyprojectHook
  ];
}
