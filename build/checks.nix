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
}
