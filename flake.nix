{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-github-actions, flake-parts, treefmt-nix }@inputs:
    let
      inherit (nixpkgs) lib;
    in
    flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        systems = [ "x86_64-linux" ];

        imports = [ inputs.treefmt-nix.flakeModule ];

        flake.githubActions = nix-github-actions.lib.mkGithubMatrix {
          checks = lib.recursiveUpdate { inherit (self.checks) x86_64-linux; } {
            x86_64-linux = {
              inherit (self.packages.x86_64-linux) doc-html;
            };
          };
        };

        flake.lib = builtins.removeAttrs (import ./lib { inherit lib; }) [ "tests" ];

        perSystem = { pkgs, ... }:
          let

            # Parse python environment from pyproject.toml
            pythonEnv =
              let
                pyproject = lib.importTOML ./pyproject.toml;
                parsedDevDeps = map self.lib.pep508.parseString pyproject.tool.pdm.dev-dependencies.dev;
              in
              pkgs.python3.withPackages (ps: map (dep: ps.${dep.name}) parsedDevDeps);

          in
          {
            treefmt.imports = [ ./dev/treefmt.nix ];

            devShells.default = pkgs.mkShell {
              packages = [
                pythonEnv
                pkgs.pdm # Python PEP-621 compliant package manager
                pkgs.hivemind # Procfile runner
                pkgs.reflex # Generic file watcher
              ];
            };

            packages.doc-html = pkgs.stdenv.mkDerivation {
              pname = "pyproject-nix-docs-html";
              version = "0.1";
              src = self;
              sourceRoot = "source/doc";
              nativeBuildInputs = [ pythonEnv pkgs.nixdoc pkgs.nixpkgs-fmt ];
              preBuild = "patchShebangs build_md.py";
              installPhase = ''
                runHook preInstall
                cp -a _build/html $out
                runHook postInstall
              '';
            };

            checks =
              let
                mkCheck = name: check: pkgs.runCommand name
                  (check.attrs or { })
                  ''
                    cp -rv ${self} src
                    chmod +w -R src
                    cd src

                    ${check.check}

                    touch $out
                  '';
              in
              lib.mapAttrs mkCheck {
                pytest = {
                  attrs = {
                    nativeBuildInputs = [
                      pkgs.nix
                      pythonEnv
                    ];
                    env.NIX_PATH = "nixpkgs=${nixpkgs}";
                  };
                  check = ''
                    export NIX_REMOTE=local?root=$PWD
                    pytest --workers auto
                  '';
                };

                # Python type checking
                mypy = {
                  attrs.nativeBuildInputs = [ pythonEnv ];
                  check = "mypy --strict .";
                };
              };

          };
      };
}
