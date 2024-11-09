{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
      ...
    }:
    let
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      inherit (nixpkgs) lib;

    in
    {
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks =
          let
            strip = lib.flip removeAttrs [
              # No need to run formatter check on multiple platforms
              "formatter"

              # Takes very long to build on Darwin and should have been adequately tested on Linux only.
              "build-make-venv-cross"
            ];

          in
          {
            inherit (self.checks) x86_64-linux;
            aarch64-darwin = strip self.checks.aarch64-darwin;
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
                (pkgs.python3.withPackages (_ps: [ ]))
                pkgs.hivemind
                pkgs.reflex
                self.formatter.${system}
              ] ++ self.packages.${system}.doc.nativeBuildInputs;
            };

        in
        {
          nix = mkShell' { inherit (pkgs) nix-unit; };

          lix = mkShell' {
            nix-unit =
              let
                lix = pkgs.lixVersions.latest;
              in
              (pkgs.nix-unit.override {
                # Hacky overriding :)
                nixVersions = lib.mapAttrs (_n: _v: lix) pkgs.nixVersions;
                # nix = pkgs.lixVersions.latest;
              }).overrideAttrs
                (_old: {
                  pname = "lix-unit";
                  name = "lix-unit-${lix.version}";
                  inherit (lix) version;
                  src = pkgs.fetchFromGitHub {
                    owner = "adisbladis";
                    repo = "lix-unit";
                    rev = "6202da22614dc0fb849e34d761621d6b1a3c110e";
                    hash = "sha256-wf45evw+BvDccVrBuFfFOZjVxh6ZI/nS7S6Lq8mv/No=";
                  };
                });
          };

          default = self.devShells.${system}.nix;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (lib.mapAttrs' (name: drv: lib.nameValuePair "nixpkgs-${name}" drv) (
          pkgs.callPackages ./test { pyproject = self; }
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
          formatter =
            pkgs.runCommand "fmt-check"
              {
                nativeBuildInputs = [ self.formatter.${system} ];
              }
              ''
                cp -r ${self} $(stripHash "${self}")
                chmod -R +w .
                cd source
                treefmt --fail-on-change
                touch $out
              '';
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.callPackage ./treefmt.nix { }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          doc = pkgs.callPackage ./doc {
            inherit self;
          };
        }
      );
    };
}
