{ lib }:
let
  inherit (builtins)
    mapAttrs
    readFile
    fromTOML
    readDir
    ;
in
lib.filterAttrs (n: _: n != "default.nix") (
  mapAttrs (name: _: fromTOML (readFile ./${name})) (readDir ./.)
)
