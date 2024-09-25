{
  pyproject-nix,
  lib,
  pkgs,
}:

let
  inherit (pyproject-nix.build.lib) isBootstrapPackage renderers;
  inherit (lib) filter attrValues isDerivation;

  python = pkgs.python312;

  # Inject your own packages on top with overrideScope
  pythonSet = pkgs.callPackage pyproject-nix.build.packages {
    inherit python;
  };

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
      crossSet = pkgs'.callPackage pyproject-nix.build.packages {
        inherit python;
      };
    in
    crossSet.pythonPkgsHostHost.mkVirtualEnv "cross-venv" {
      build = [ ];
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

  # Bootstrap dependencies need to use pyprojectBootstrapHook
  overriden-bootstrap-dep =
    let
      overlay = final: _prev: {
        packaging = final.stdenv.mkDerivation {
          pname = "packaging";
          version = "24.1";

          src = pkgs.fetchurl {
            url = "https://files.pythonhosted.org/packages/51/65/50db4dda066951078f0a96cf12f4b9ada6e4b811516bf0262c0f4f7064d4/packaging-24.1.tar.gz";
            hash = "sha256-Am7XLI7T/M5b+JUFciWGmJJ/0dvaEKXpgc3wrDf08AI=";
          };

          nativeBuildInputs =
            assert isBootstrapPackage "packaging";
            [
              final.pyprojectBootstrapHook
            ]
            ++ final.resolveBuildSystem {
              flit-core = [ ];
            };
        };
      };

      pythonSet' = pythonSet.overrideScope (
        _final: prev: {
          pythonPkgsBuildHost = prev.pythonPkgsBuildHost.overrideScope overlay;
        }
      );

    in
    pythonSet'.pythonPkgsHostHost.mkVirtualEnv "overriden-bootstrap-venv" {
      build = [ ];
    };

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
        myapp = [ "toml" ];
      };
    in
    pkgs.runCommand "render-mkderivation-test" { nativeBuildInputs = [ venv ]; } ''
      # Assert that extra was enabled
      python -c "import tomli_w"

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
