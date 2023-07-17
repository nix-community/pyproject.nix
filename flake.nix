{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nix-github-actions }:
    let
      inherit (nixpkgs) lib;
    in
    {
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = { inherit (self.checks) x86_64-linux; };
      };

      lib = builtins.removeAttrs (import ./lib { inherit lib; }) [ "tests" ];

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        pythonEnv =
          let
            pyproject = lib.importTOML ./pyproject.toml;
            parsedDevDeps = map self.lib.pep508.parseString pyproject.tool.pdm.dev-dependencies.dev;
          in
          pkgs.python3.withPackages (ps: map (dep: ps.${dep.name}) parsedDevDeps);

      in
      {

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.treefmt
            pkgs.deadnix
            pkgs.statix
            pkgs.nixpkgs-fmt
            pythonEnv
            pkgs.pdm
          ];

          shellHook = ''
            export NIX_PATH=nixpkgs=${nixpkgs}
          '';
        };

        checks =
          let
            mkCheck = name: check: pkgs.runCommand name
              {
                nativeBuildInputs = self.devShells.${system}.default.nativeBuildInputs ++ [
                  pkgs.nix
                ];
                env.NIX_PATH = "nixpkgs=${nixpkgs}";
              } ''
              cp -rv ${self} src
              chmod +w -R src
              cd src

              export NIX_REMOTE=local?root=$PWD

              ${check}

              touch $out
            '';
          in
          {
            pytest = mkCheck "pytest" "pytest --workers auto";
            treefmt = mkCheck "treefmt" "treefmt --no-cache --fail-on-change";
            deadnix = mkCheck "deadnix" "deadnix --fail";
            statix = mkCheck "statix" "statix check";
          };

      });
}
