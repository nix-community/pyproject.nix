{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.deprecation)
    pname
    version
    src
    meta
    ;

  passthru.dependencies = {
    packaging = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
