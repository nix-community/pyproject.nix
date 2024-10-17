{
  stdenv,
  flit-core,
  pythonPackages,
  pyprojectHook,
  resolveBuildSystem,
}:

stdenv.mkDerivation {
  inherit (pythonPackages.installer)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs =
    [ pyprojectHook ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
