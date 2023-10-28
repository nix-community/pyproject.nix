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
    , ...
    }:
    let
      pyproject = import (pyproject-nix + "/lib") { inherit (nixpkgs) lib; };

      # Load/parse requirements.txt
      project = pyproject.project.loadRequirementsTxt {
        requirements = ./requirements.txt;
      };

    in
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python3;

      pythonEnv =
        # Assert that versions from nixpkgs matches what's described in requirements.txt
        # In projects that are overly strict about pinning it might be best to remove this assertion entirely.
        assert pyproject.validators.validateVersionConstraints { inherit project python; } == { }; (
          # Render requirements.txt into a Python withPackages environment
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
