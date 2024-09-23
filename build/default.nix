{ lib, pyproject-nix }:

lib.fix (self: {
  packages = import ./packages.nix {
    inherit (self.lib) resolvers;
    inherit pyproject-nix lib;
  };
  lib = import ./lib { inherit lib pyproject-nix; };
})
