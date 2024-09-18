{
  stdenv,
  lib,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.scikit-build)
    pname
    version
    src
    meta
    patches
    ;

  passthru.dependencies =
    {
      distro = [ ];
      packaging = [ ];
      setuptools = [ ];
      wheel = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.11") {
      tomli = [ ];
    }
    // lib.optionalAttrs (python.pythonOlder "3.8") {
      typing-extensions = [ ];
    };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      hatchling = [ ];
      hatch-vcs = [ ];
      hatch-fancy-pypi-readme = [ ];
    };
}
