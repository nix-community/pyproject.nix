{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.calver)
    pname
    version
    src
    meta
    postPatch
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
