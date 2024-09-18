{
  stdenv,
  python3Packages,
  pyprojectHook,
  flit-core,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pyproject-hooks)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
