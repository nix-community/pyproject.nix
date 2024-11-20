{ pkgs, pyproject-nix }:

let
  inherit (pkgs) lib;

  hacks = pkgs.callPackages pyproject-nix.build.hacks { };

  python = pkgs.python3;

  testOverlay = import ../test_overlay.nix {
    inherit pyproject-nix lib;
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      testOverlay;

in
{
  nixpkgsPrebuilt =
    let
      testSet = pythonSet.overrideScope (
        _final: prev: {
          # Arbitrary test package with a bin output we can run
          pip = hacks.nixpkgsPrebuilt {
            from = pkgs.python3Packages.pip;
            prev = prev.pip;
          };
        }
      );

      drv = testSet.pip;

      venv = testSet.mkVirtualEnv "nixpkgsPrebuilt-check-venv" {
        pip = [ ];
      };

    in
    pkgs.runCommand "nixpkgsPrebuilt-check" { } ''
      # Check that no wrapped files are in output
      ! ls -a ${drv}/bin | grep wrapped

      # Check that file does not contain any store references apart from shebang
      tail -n +2 ${drv}/bin/pip > script
      ! grep "${builtins.storeDir}" script

      # Test run binary
      ${venv}/bin/pip --help > /dev/null

      ln -s ${venv} $out
    '';

  importCargoLock =
    let
      testSet = pythonSet.overrideScope (
        lib.composeExtensions
          (final: _prev: {
            cryptography = final.callPackage (
              {
                stdenv,
                pyprojectHook,
              }:
              stdenv.mkDerivation {
                inherit (pkgs.python3Packages.cryptography) pname version src;

                nativeBuildInputs = [
                  pyprojectHook
                ];
              }
            ) { };
          })
          (
            final: prev: {
              cryptography =
                (hacks.importCargoLock {
                  prev = prev.cryptography;
                  cargoRoot = "src/rust";
                }).overrideAttrs
                  (old: {
                    nativeBuildInputs =
                      old.nativeBuildInputs
                      ++ final.resolveBuildSystem {
                        maturin = [ ];
                        setuptools = [ ];
                        cffi = [ ];
                        pycparser = [ ];
                      };
                    buildInputs = old.buildInputs or [ ] ++ [ pkgs.openssl ];
                  });
            }
          )
      );

      venv = testSet.mkVirtualEnv "nixpkgsPrebuilt-check-venv" {
        cryptography = [ ];
      };

    in
    pkgs.runCommand "importCargoLock-check" { } ''
      ${venv}/bin/python -c "import cryptography"
      ln -s ${venv} $out
    '';

}
