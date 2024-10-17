{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.hatch-fancy-pypi-readme)
    pname
    version
    src
    meta
    ;

  passthru.dependencies = {
    hatchling = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
    };
}
