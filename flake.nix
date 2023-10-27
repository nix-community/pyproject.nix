{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    proc-flake.url = "github:srid/proc-flake";
    flake-root.url = "github:srid/flake-root";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

    nix-unit.url = "github:adisbladis/nix-unit";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";

    nixdoc.url = "github:nix-community/nixdoc";
    nixdoc.inputs.nixpkgs.follows = "nixpkgs";
    mdbook-nixdoc.url = "github:adisbladis/mdbook-nixdoc";
    mdbook-nixdoc.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-github-actions, flake-parts, treefmt-nix, nix-unit, nixdoc, ... }@inputs:
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
          inputs.flake-root.flakeModule
          inputs.proc-flake.flakeModule
          ./flake-module.nix
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

        perSystem = { pkgs, config, system, ... }:
          let
            nixUnit = nix-unit.packages.${system}.nix-unit;
          in
          {
            treefmt.imports = [ ./dev/treefmt.nix ];

            checks = pkgs.callPackages ./test
              {
                pyproject = import ./default.nix { inherit pkgs lib; };
              } // self.packages.${system} // {
              mypy = pkgs.runCommand "pyproject.nix-mypy" { nativeBuildInputs = [ pkgs.python3.pkgs.mypy ]; } ''
                mypy --exclude doc --strict ${self}
                touch $out
              '';
            };

            fetchers = import ./fetchers { inherit pkgs lib; };

            proc.groups.run.processes = {
              nix-unittest.command = "${lib.getExe' pkgs.reflex "reflex"} -r '\.(nix)$' -- ${lib.getExe' nixUnit "nix-unit"} --quiet --flake '.#libTests'";
              mdbook.command = "(cd doc && mdbook serve)";
            };

            devShells.default = pkgs.mkShell {
              inputsFrom = [ config.flake-root.devShell ]; # Provides $FLAKE_ROOT in dev shell
              packages = [
                config.proc.groups.run.package
                nixUnit
                inputs.mdbook-nixdoc.packages.${system}.default
              ] ++ self.packages.${system}.doc.nativeBuildInputs;
            };

            packages.doc = pkgs.callPackage ./doc {
              inherit self;
              nixdoc = nixdoc.packages.${system}.default;
              mdbook-nixdoc = inputs.mdbook-nixdoc.packages.${system}.default;
            };
          };
      };
}
