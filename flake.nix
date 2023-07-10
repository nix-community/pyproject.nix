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

      devShells = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          pythonEnv = pkgs.python3.withPackages (ps: [
            # Testing utilities
            ps.pytest
            ps.pytest-parallel

            # Formatters/linters
            ps.black
          ]);

        in
        {
          default = pkgs.mkShell {
            packages = [
              pythonEnv
            ];
          };
        });
    };
}
