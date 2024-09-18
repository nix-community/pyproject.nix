{
  stdenv,
  python,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.pybind11)
    pname
    version
    src
    meta
    propagatedNativeBuildInputs # setupHook
    dontUseCmakeBuildDir
    cmakeFlags
    hardeningDisable
    ;

  postInstall = ''
    # Symlink the CMake-installed headers to the location expected by setuptools
    mkdir -p $out/include/${python.libPrefix}
    ln -sf $out/include/pybind11 $out/include/${python.libPrefix}/pybind11
  '';

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      cmake = [ ];
      ninja = [ ];
      setuptools = [ ];
    };
}
