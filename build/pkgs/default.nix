{ lib, pyproject-nix }:

let
  inherit (pyproject-nix.build.lib) isBootstrapPackage;
  inherit (lib) mapAttrs filterAttrs;
  inherit (builtins) readDir;

  # List all packages in directory
  paths = filterAttrs (_name: type: type == "directory") (readDir ./.);

in
{ callPackage, pyprojectBootstrapHook }:
# Automatically call all packages
(mapAttrs (
  name: _:
  callPackage (./. + "/${name}") (
    # Override bootstrap packages with bootstrap hook
    if isBootstrapPackage name then
      {
        pyprojectHook = pyprojectBootstrapHook;
      }
    else
      { }
  )
) paths)
