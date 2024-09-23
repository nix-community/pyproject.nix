{ lib, pyproject-nix }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) fix elem flip;
in

fix (
  self:
  mapAttrs (_: path: import path ({ inherit pyproject-nix lib; } // self)) {
    renderers = ./renderers.nix;
    resolvers = ./resolvers.nix;
  }
  // {

    isBootstrapPackage = flip elem [
      "flit-core"
      "pyproject-hooks"
      "packaging"
      "build"
    ];
  }
)
