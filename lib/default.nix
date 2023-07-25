{ lib }:

lib.fix (self: lib.mapAttrs (_: path: import path ({ inherit lib; } // self)) {
  pypa = ./pypa.nix;
  filter = ./filter.nix;

  pep427 = ./pep427.nix;
  pep440 = ./pep440.nix;
  pep508 = ./pep508.nix;
  pep518 = ./pep518.nix;
  pep599 = ./pep599.nix;
  pep600 = ./pep600.nix;
  pep621 = ./pep621.nix;
})
