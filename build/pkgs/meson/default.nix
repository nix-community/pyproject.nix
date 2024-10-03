{
  stdenv,
  pyprojectHook,
  resolveBuildSystem,
  pkgs,
  lib,
  python,
}:
stdenv.mkDerivation {
  inherit (pkgs.meson)
    pname
    version
    src
    meta
    patches
    setupHook
    ;

  passthru.optional-dependencies = {
    ninja = {
      ninja = [ ];
    };
    progess = {
      tqdm = [ ];
    };
    typing =
      {
        mypy = [ ];
      }
      // lib.optionalAttrs (python.pythonOlder "3.8") {
        typing-extensions = [ ];
      };
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
