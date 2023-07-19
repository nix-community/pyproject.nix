{ lib }:

lib.mapAttrs (_: path: import path { inherit lib; }) {
  pep508 = ./pep508.nix;
}
