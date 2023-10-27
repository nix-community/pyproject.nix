{
  description = "Construct development shell from requirements.txt";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.pyproject-nix.url = "github:nix-community/pyproject.nix";
  inputs.pyproject-nix.flake = false; # Don't use the pyproject.nix flake directly to avoid it's inputs in our closure

  outputs =
    { nixpkgs
    , flake-utils
    , pyproject-nix
    }:
    let
      pyproject = import (pyproject-nix + "/lib") { inherit (nixpkgs) lib; };

      project = pyproject.project.loadRequirementsTxt {
        requirements = ./requirements.txt;
      };

    in
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python3;

      pythonEnv = assert pyproject.validators.validateVersionConstraints { inherit project python; } == { }; (
        pkgs.python3.withPackages (pyproject.renderers.withPackages {
          inherit project python;
        })
      );

    in
    {
      devShell =
        pkgs.mkShell {
          packages = [
            pythonEnv
          ];
        };
    });
}
