{ lib }:

lib.fix (self: lib.mapAttrs (_: path: import path ({ inherit lib; } // self)) {
  pep440 = ./pep440.nix;
  pep508 = ./pep508.nix;
})
