{ pyproject-nix, pkgs }:

let
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
}
