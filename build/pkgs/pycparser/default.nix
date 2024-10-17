{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pycparser)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    pyprojectHook
  ] ++ resolveBuildSystem { };
}
