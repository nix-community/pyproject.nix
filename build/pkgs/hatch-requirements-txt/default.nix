{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation (_finalAttrs: {
  inherit (python3Packages.hatch-requirements-txt)
    pname
    version
    src
    meta
    ;

  passthru.dependencies = {
    hatchling = [ ];
    packaging = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
    };
})
