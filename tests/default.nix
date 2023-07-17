{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
}:
let
  pyLib = import ../lib { inherit lib; };

in
{
  # Applies attrNames to tests so we can just dump the JSON to get the test suite names
  discovery = lib.mapAttrs (_: module: lib.mapAttrs (_: tests: lib.attrNames tests) module) pyLib.tests;
  inherit (pyLib) tests;
}
