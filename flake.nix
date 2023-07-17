{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      eachSystem = lib.genAttrs [ "x86_64-linux" ];
    in
    {
      libChecks = (import ./lib { inherit lib; }).tests;
      lib = import ./lib { inherit lib; };

      devShells = eachSystem (system:
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
          default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.pdm
            ];
          };
        });
    };
}
