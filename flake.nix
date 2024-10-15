{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

    mdbook-nixdoc.url = "github:adisbladis/mdbook-nixdoc";
    mdbook-nixdoc.inputs.nixpkgs.follows = "nixpkgs";
    mdbook-nixdoc.inputs.nix-github-actions.follows = "nix-github-actions";

    lix-unit = {
      url = "github:adisbladis/lix-unit";
      inputs.mdbook-nixdoc.follows = "mdbook-nixdoc";
      inputs.nix-github-actions.follows = "nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
      treefmt-nix,
      lix-unit,
      ...
    }@inputs:
    let
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      inherit (nixpkgs) lib;

    in
    # treefmtEval = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./dev/treefmt.nix);
    {
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = {
          inherit (self.checks) x86_64-linux;
        };
      };

      # Note: This build infrastructure is experimental.
      build = import ./build {
        pyproject-nix = self;
        inherit lib;
      };

      lib = import ./lib { inherit lib; };

      templates =
        let
          root = ./templates;
          dirs = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir root));
        in
        lib.listToAttrs (
          map (
            dir:
            let
              path = root + "/${dir}";
              template = import (path + "/flake.nix");
            in
            lib.nameValuePair dir {
              inherit path;
              inherit (template) description;
            }
          ) dirs
        );

      # Expose unit tests for external discovery
      libTests =
        import ./lib/test.nix {
          inherit lib;
          pyproject = self.lib;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        }
        // {
          build = import ./build/lib/test.nix {
            pyproject-nix = self;
            inherit lib;
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          };
        };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkShell' =
            { nix-unit }:
            pkgs.mkShell {
              packages = [
                nix-unit
                inputs.mdbook-nixdoc.packages.${system}.default
                (pkgs.python3.withPackages (_ps: [ ]))
                pkgs.hivemind
                pkgs.reflex
              ] ++ self.packages.${system}.doc.nativeBuildInputs;
            };

        in
        {
          nix = mkShell' { inherit (pkgs) nix-unit; };
          lix = mkShell' { nix-unit = lix-unit.packages.${system}.default; };
          default = self.devShells.${system}.nix;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (lib.mapAttrs' (name: drv: lib.nameValuePair "nixpkgs-${name}" drv) (
          pkgs.callPackages ./test { pyproject = import ./default.nix { inherit lib; }; }
        ))
        // (lib.mapAttrs' (name: drv: lib.nameValuePair "build-${name}" drv) (
          pkgs.callPackages ./build/checks { pyproject-nix = self; }
        ))
        // (lib.mapAttrs' (name: drv: lib.nameValuePair "build-hacks-${name}" drv) (
          pkgs.callPackages ./build/hacks/checks.nix {
            pyproject-nix = self;
          }
        ))
        // {
          formatter = pkgs.writeShellScript "fmt-check" ''
            set -euo pipefail
            find "$1" -name '*.nix' | while read f; do
              ${lib.getExe pkgs.deadnix} --fail "$f"
              ${lib.getExe pkgs.statix} check "$f"
              ${lib.getExe pkgs.nixpkgs-fmt} --check "$f"
            done
          '';
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (treefmt-nix.lib.evalModule pkgs ./dev/treefmt.nix).config.build.wrapper
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          doc = pkgs.callPackage ./doc {
            inherit self;
            mdbook-nixdoc = inputs.mdbook-nixdoc.packages.${system}.default;
          };
        }
      );
    };
}
