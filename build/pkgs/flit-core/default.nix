{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation {
  inherit (python3Packages.flit-core)
    pname
    version
    src
    meta
    patches
    ;
  postPatch = python3Packages.flit-core.postPatch or null;
  sourceRoot = python3Packages.flit-core.sourceRoot or null;
  nativeBuildInputs = [
    pyprojectHook
  ];
}
