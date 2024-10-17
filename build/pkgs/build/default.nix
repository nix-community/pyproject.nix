{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.build)
    pname
    version
    src
    meta
    ;

  passthru.dependencies =
    {
      packaging = [ ];
      pyproject-hooks = [ ];

    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
    };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
