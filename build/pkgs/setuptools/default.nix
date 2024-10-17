{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.setuptools)
    pname
    version
    src
    meta
    patches
    preBuild # Skips windows files
    ;

  passthru.dependencies.wheel = [ ];

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
