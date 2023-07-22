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
  };

  outputs = { self, nixpkgs, nix-github-actions, flake-parts, treefmt-nix, nix-unit, ... }@inputs:
    let
      inherit (nixpkgs) lib;

    in
    flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        systems = [ "x86_64-linux" ];

        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.flake-root.flakeModule
          inputs.proc-flake.flakeModule
        ];

        flake.githubActions = nix-github-actions.lib.mkGithubMatrix {
          checks = lib.recursiveUpdate { inherit (self.checks) x86_64-linux; } {
            x86_64-linux = {
              inherit (self.packages.x86_64-linux) doc;
            };
          };
        };

        flake.lib = import ./lib { inherit lib; };

        # Expose unit tests for external discovery
        flake.libTests = import ./lib/test.nix { inherit lib; pyproject = self.lib; };

        perSystem = { pkgs, config, system, ... }:
          let
            nixUnit = nix-unit.packages.${system}.nix-unit;
          in
          {
            treefmt.imports = [ ./dev/treefmt.nix ];

            proc.groups.run.processes = {
              nix-unittest.command = "${lib.getExe pkgs.reflex} -r '\.(nix)$' -- ${lib.getExe nixUnit} --flake '.#libTests'";
            };

            devShells.default = pkgs.mkShell {
              inputsFrom = [ config.flake-root.devShell ]; # Provides $FLAKE_ROOT in dev shell
              packages = [
                config.proc.groups.run.package
                nixUnit
              ];
            };

            packages.doc = pkgs.callPackage ./doc { inherit self; };
          };
      };
}
