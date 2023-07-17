{ lib }:
let
  modules = lib.mapAttrs (_: path: import path { inherit lib; }) {
    pep508 = ./pep508.nix;
  };

in
modules // {
  tests = lib.mapAttrs (_: mod: mod.tests) modules;
}
