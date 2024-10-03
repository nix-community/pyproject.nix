{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.poetry-dynamic-versioning)
    pname
    version
    src
    meta
    setupHook
    ;

  passthru.dependencies = {
    dunamai = [ ];
    jinja2 = [ ];
    tomlkit = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      poetry-core = [ ];
    };
}
