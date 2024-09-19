{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation (_finalAttrs: {
  inherit (python3Packages.hatch-vcs)
    pname
    version
    src
    meta
    ;

  passthru.dependencies = {
    hatchling = [ ];
    setuptools-scm = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
    };
})
