{
  stdenv,
  pyprojectHook,
  resolveBuildSystem,
  python3Packages,
}:
stdenv.mkDerivation {
  inherit (python3Packages.oldest-supported-numpy)
    pname
    version
    src
    meta
    postPatch
    ;

  passthru.dependencies = {
    numpy = [ ];
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
      wheel = [ ];
    };
}
