{
  stdenv,
  pyprojectHook,
  resolveBuildSystem,
  python3Packages,
}:
stdenv.mkDerivation {
  inherit (python3Packages.versioneer)
    pname
    version
    src
    meta
    ;

  passthru.optional-dependencies.toml = {
    tomli = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
