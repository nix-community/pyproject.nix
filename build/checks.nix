{ pyproject-nix, pkgs }:

let
  inherit (pyproject-nix.build.lib) isBootstrapPackage;

  python = pkgs.python312;

  # Inject your own packages on top with overrideScope
  pythonSet = pkgs.callPackage pyproject-nix.build.packages {
    inherit python;
  };

  testVenv = pythonSet.pythonPackagesHostHost.mkVirtualEnv "test-venv" {
    build = [ ];
  };

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

  prebuilt-wheel = pythonSet.pythonPackagesHostHost.callPackage (
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

  # Bootstrap dependencies need to pyprojectBootstrapHook
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
          pythonPackagesBuildHost = prev.pythonPackagesBuildHost.overrideScope overlay;
        }
      );

    in
    pythonSet'.pythonPackagesHostHost.mkVirtualEnv "overriden-bootstrap-venv" {
      build = [ ];
    };
}
