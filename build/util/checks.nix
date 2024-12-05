{ pkgs, pyproject-nix }:

let
  inherit (pkgs) lib;

  util = pkgs.callPackages pyproject-nix.build.util { };

  python = pkgs.python3;

  buildSystems = import ../checks/build-systems.nix {
    inherit lib;
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      buildSystems;

in
{
  mkApplication =
    let
      drv = pythonSet.pip;

      venv = pythonSet.mkVirtualEnv "mkApplication-check-venv" {
        pip = [ ];
      };

      app = util.mkApplication {
        inherit venv;
        package = drv;
      };

    in
    pkgs.runCommand "mkApplication-check" { } ''
      # Test run binary
      ${app}/bin/pip --help > /dev/null

      ln -s ${app} $out
    '';

}
