{ lib, pyproject-nix }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) fix elem flip;
in

fix (
  self:
  {
    /*
      Check if a package is a bootstrap package by it's name.

      This needs to be used by lockfile consumers to check if a package needs pyprojectBootstrapHook instead of pyprojectHook.
    */
    isBootstrapPackage = flip elem [
      "flit-core"
      "pyproject-hooks"
      "packaging"
      "build"
    ];
  }
  // mapAttrs (_: path: import path ({ inherit pyproject-nix lib; } // self)) {
    renderers = ./renderers.nix;
    resolvers = ./resolvers.nix;
  }
)
