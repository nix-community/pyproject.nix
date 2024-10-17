{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
  pkgs,
}:
stdenv.mkDerivation {
  inherit (python3Packages.setuptools-git)
    pname
    version
    src
    meta
    ;

  propagatedBuildInputs = [ pkgs.git ];

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
    };
}
