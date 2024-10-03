{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.jupyter-packaging)
    pname
    version
    src
    meta
    ;

  passthru.dependencies = {
    deprecation = [ ];
    packaging = [ ];
    setuptools = [ ];
    tomlkit = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
    };
}
