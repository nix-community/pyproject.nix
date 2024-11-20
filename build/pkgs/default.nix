{ lib, pyproject-nix }:

let
  inherit (lib) mapAttrs filterAttrs;
  inherit (builtins) readDir;

  # List all packages in directory
  paths = filterAttrs (_name: type: type == "directory") (readDir ./.);

in
{ callPackage }:
# Automatically call all packages
(mapAttrs (name: _: callPackage (./. + "/${name}") { }) paths)
