{
  pyproject-nix,
  lib,
  pkgs,
}:

let
  inherit (pyproject-nix.build.lib) renderers;
  inherit (lib) filter attrValues isDerivation;

  python = pkgs.python312;

  buildSystems = import ./build-systems.nix {
    inherit lib;
  };

  # Inject your own packages on top with overrideScope
  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      buildSystems;

  testVenv = pythonSet.pythonPkgsHostHost.mkVirtualEnv "test-venv" {
    build = [ ];
  };

  # Test fixture
  myapp = pyproject-nix.lib.project.loadPyproject {
    projectRoot = ./fixtures/myapp;
  };

  testEnviron = pyproject-nix.lib.pep508.mkEnviron python;

in

{
  make-venv =
    pkgs.runCommand "venv-run-build-test"
      {
        nativeBuildInputs = [ testVenv ];
      }
      ''
        pyproject-build --help > /dev/null
        touch $out
      '';

  make-venv-cross =
    let
      pkgs' = pkgs.pkgsCross.aarch64-multiplatform;
      python = pkgs'.python312;
      crossSet =
        (pkgs'.callPackage pyproject-nix.build.packages {
          inherit python;
        }).overrideScope
          buildSystems;
    in
    crossSet.mkVirtualEnv "cross-venv" {
      build = [ ];
      cffi = [ ];
    };

  prebuilt-wheel = pythonSet.pythonPkgsHostHost.callPackage (
    {
      stdenv,
      fetchurl,
      pyprojectWheelHook,
    }:
    stdenv.mkDerivation {
      pname = "arpeggio";
      version = "2.0.2";

      src = fetchurl {
        url = "https://files.pythonhosted.org/packages/f7/4f/d28bf30a19d4649b40b501d531b44e73afada99044df100380fd9567e92f/Arpeggio-2.0.2-py2.py3-none-any.whl";
        hash = "sha256-98iuT0BWqJ4CDCTHICrI3z4ryE5BZ0byCw2jW7HeAlA=";
      };

      nativeBuildInputs = [ pyprojectWheelHook ];
    }
  ) { };

  full-set =
    let
      pythonSetDrvs = filter isDerivation (attrValues pythonSet.pythonPkgsHostHost);
      hooks = attrValues pythonSet.pythonPkgsHostHost.hooks;
      pythonDrvs = filter (
        drv:
        !lib.elem drv hooks
        && !lib.elem (drv.pname or drv.name) [
          "pyproject-hook"
          "python3"
          "stdenv-linux"
          "stdenv-darwin"
        ]
      ) pythonSetDrvs;

      full-set-venv = pythonSet.pythonPkgsHostHost.mkVirtualEnv "test-venv" (
        lib.listToAttrs (map (drv: lib.nameValuePair (drv.pname or drv.name) [ ]) pythonDrvs)
      );
    in
    full-set-venv;

  mkderivation =
    let
      testSet = pythonSet.pythonPkgsHostHost.overrideScope (
        final: _prev: {
          myapp = final.callPackage (
            {
              stdenv,
              pyprojectHook,
              resolveBuildSystem,
            }:
            stdenv.mkDerivation (
              renderers.mkDerivation
                {
                  project = myapp;
                  environ = testEnviron;
                }
                {
                  inherit pyprojectHook resolveBuildSystem;
                }
            )
          ) { };
        }
      );

      venv = testSet.mkVirtualEnv "render-mkderivation-env" {
        myapp = [
          "toml" # Extra
          "round" # PEP-735 dependency group
        ];
      };
    in
    pkgs.runCommand "render-mkderivation-test" { nativeBuildInputs = [ venv ]; } ''
      # Assert that extra was enabled
      python -c "import tomli_w"

      # Assert that dependency group was enabled
      python -c "import wheel"

      # Script from myapp
      hello

      touch $out
    '';

  mkderivation-editable =
    let
      testSet = pythonSet.pythonPkgsHostHost.overrideScope (
        final: _prev: {
          myapp = final.callPackage (
            {
              python,
              stdenv,
              pyprojectHook,
              resolveBuildSystem,
              pythonPkgsBuildHost,
            }:
            stdenv.mkDerivation (
              renderers.mkDerivationEditable
                {
                  project = myapp;
                  environ = testEnviron;
                  root = "$NIX_BUILD_TOP/src";
                }
                {
                  inherit
                    python
                    pyprojectHook
                    resolveBuildSystem
                    pythonPkgsBuildHost
                    ;
                }
            )
          ) { };
        }
      );

      venv = testSet.mkVirtualEnv "render-mkderivation-editable-env" {
        myapp = [ ];
      };

    in
    pkgs.runCommand "render-mkeditable" { nativeBuildInputs = [ venv ]; } ''
      # Unpack sources into build
      cp -r ${./fixtures/myapp}/* .
      chmod +w -R src

      hello | grep "Hello from myapp"

      cat > src/myapp/__init__.py <<EOF
      def hello() -> None:
          print("Hello from editable!")
      EOF

      hello | grep "Hello from editable"

      touch $out
    '';

}
