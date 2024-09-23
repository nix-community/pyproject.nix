{
  stdenv,
  python,
  pyprojectInstallHook,
  pyprojectBytecodeHook,
  pyprojectOutputSetupHook,
  python3Packages,
}:

let

  buildBootstrapPackage =
    base: attrs:
    stdenv.mkDerivation (
      {
        inherit (base)
          pname
          src
          patches
          version
          meta
          ;
        dontConfigure = true;
        nativeBuildInputs = [
          python
          pyprojectInstallHook
          pyprojectBytecodeHook
          pyprojectOutputSetupHook
        ];
        buildPhase = ''
          runHook preBuild

          PYTHONPATH="${bootstrap.flit-core}/${python.sitePackages}" \
            ${python.interpreter} -m flit_core.wheel

          runHook postBuild
        '';
      }
      // attrs
    );

  bootstrap = {
    flit-core = buildBootstrapPackage python3Packages.flit-core {
      sourceRoot = "${python3Packages.flit-core.src.name}/flit_core";
      buildPhase = ''
        runHook preBuild
        ${python.interpreter} -m flit_core.wheel
        runHook postBuild
      '';
    };
    pyproject-hooks = buildBootstrapPackage python3Packages.pyproject-hooks { };
    packaging = buildBootstrapPackage python3Packages.packaging { };
    build = buildBootstrapPackage python3Packages.build {
      passthru.dependencies = {
        packaging = [ ];
        pyproject-hooks = [ ];
      };
    };
  };

in
bootstrap
