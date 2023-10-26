{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
mkTransposedPerSystemModule {
  name = "fetchers";
  option = mkOption {
    type = types.lazyAttrsOf types.raw;
    default = { };
    description = ''
      Top-level flake attribute for fetchers.
    '';
  };
  file = ./flake-module.nix;
}
