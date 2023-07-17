{ lib }:
let
  modules = lib.mapAttrs (_: path: import path { inherit lib; }) {
    pep508 = ./pep508.nix;
  };

in
(lib.mapAttrs (_: v: builtins.removeAttrs v [ "tests" ]) modules) // {
  tests = lib.mapAttrs (_: mod: mod.tests) modules;
}
