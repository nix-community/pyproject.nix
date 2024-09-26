{
  stdenv,
  python,
  pyprojectInstallHook,
  pyprojectBytecodeHook,
  pyprojectOutputSetupHook,
  python3Packages,
  lib,
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
      passthru.dependencies =
        {
          packaging = [ ];
          pyproject-hooks = [ ];
        }
        // lib.optionalAttrs (python.pythonOlder "3.11") {
          tomli = [ ];
        };
    };
    # Pre Python 3.11 the standard library had no way of reading toml,
    # so build-systems have to use a third party package.
    #
    # To not complicate bootstrapping for older Pythons we simply unpack this, and put it on sys.path.
    tomli = stdenv.mkDerivation {
      inherit (python3Packages.tomli) pname version src;
      nativeBuildInputs = [
        pyprojectBytecodeHook
        pyprojectOutputSetupHook
      ];
      installPhase = ''
        mkdir -p $out/${python.sitePackages}
        cp -r src/tomli $out/${python.sitePackages}/
      '';
    };
  };

in
bootstrap
