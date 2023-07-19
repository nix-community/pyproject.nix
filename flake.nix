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
  };

  outputs = { self, nixpkgs, nix-github-actions, flake-parts, treefmt-nix, ... }@inputs:
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
        flake.libTests = import ./lib/test.nix { inherit lib; pyproject = self.lib; };

        perSystem = { pkgs, config, system, ... }:
          {
            treefmt.imports = [ ./dev/treefmt.nix ];

            proc.groups.run.processes = {
              nix-unittest.command = "${lib.getExe pkgs.reflex} -r '\.(nix)$' -- nix build --log-format raw-with-logs --quiet .#checks.${system}.unittest";
            };

            devShells.default = pkgs.mkShell {
              inputsFrom = [ config.flake-root.devShell ]; # Provides $FLAKE_ROOT in dev shell
              packages = [ config.proc.groups.run.package ];
            };

            packages.doc = pkgs.callPackage ./doc { inherit self; };

            # Dump all unit tests as a JSON and assert that the output from lib.debug.runTests is empty in all cases
            checks.unittest =
              pkgs.runCommand "unittest"
                {
                  nativeBuildInputs = [ pkgs.jq ];
                  env.RESULTS = builtins.toJSON (lib.mapAttrs (_: lib.mapAttrs (_: lib.debug.runTests)) self.libTests);
                  allowSubstitutes = false;
                } ''
                echo "$RESULTS" | jq
                echo "$RESULTS" | jq '.[] | .[] | length == 0 // error("Tests failed!")' > /dev/null
                touch $out
              '';
          };
      };
}
