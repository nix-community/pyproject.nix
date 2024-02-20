{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

    mdbook-nixdoc.url = "github:adisbladis/mdbook-nixdoc";
    mdbook-nixdoc.inputs.nixpkgs.follows = "nixpkgs";
    mdbook-nixdoc.inputs.nix-github-actions.follows = "nix-github-actions";
  };

  outputs = { self, nixpkgs, nix-github-actions, flake-parts, treefmt-nix, ... }@inputs:
    let
      inherit (nixpkgs) lib;

    in
    flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        flake.githubActions = nix-github-actions.lib.mkGithubMatrix {
          checks = { inherit (self.checks) x86_64-linux; };
        };

        flake.lib = import ./lib { inherit lib; };

        flake.templates =
          let
            root = ./templates;
            dirs = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir root));
          in
          lib.listToAttrs (
            map
              (
                dir:
                let
                  path = root + "/${dir}";
                  template = import (path + "/flake.nix");
                in
                lib.nameValuePair dir {
                  inherit path; inherit (template) description;
                }
              )
              dirs
          );

        # Expose unit tests for external discovery
        flake.libTests = import ./lib/test.nix {
          inherit lib; pyproject = self.lib;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };

        perSystem = { pkgs, system, ... }:
          {
            treefmt.imports = [ ./dev/treefmt.nix ];

            checks = pkgs.callPackages ./test {
              pyproject = import ./default.nix { inherit lib; };
            };

            devShells.default = pkgs.mkShell {
              packages = [
                pkgs.nix-unit
                inputs.mdbook-nixdoc.packages.${system}.default
                (pkgs.python3.withPackages (_ps: [ ]))
                pkgs.hivemind
                pkgs.reflex
              ] ++ self.packages.${system}.doc.nativeBuildInputs;
            };

            packages.doc = pkgs.callPackage ./doc {
              inherit self;
              mdbook-nixdoc = inputs.mdbook-nixdoc.packages.${system}.default;
            };
          };
      };
}
