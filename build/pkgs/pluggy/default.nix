{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
  setuptools-scm,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pluggy)
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
      setuptools-scm = [ ];
    };
}
