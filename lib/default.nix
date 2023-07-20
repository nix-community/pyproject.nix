{ lib }:

lib.mapAttrs (_: path: import path { inherit lib; }) {
  pep440 = ./pep440.nix;
  pep508 = ./pep508.nix;
}
