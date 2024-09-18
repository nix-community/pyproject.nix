{ lib }:

let
  # List all packages in directory
  paths = lib.filterAttrs (_name: type: type == "directory") (builtins.readDir ./.);

in
{ callPackage, pyprojectBootstrapHook }:
# Automatically call all packages
(lib.mapAttrs (name: _: callPackage (./. + "/${name}") { }) paths)
//
  # Override bootstrap packages with bootstrap hook
  {
    build = callPackage ./build {
      pyprojectHook = pyprojectBootstrapHook;
    };
    flit-core = callPackage ./flit-core {
      pyprojectHook = pyprojectBootstrapHook;
    };
    packaging = callPackage ./packaging {
      pyprojectHook = pyprojectBootstrapHook;
    };
    pyproject-hooks = callPackage ./pyproject-hooks {
      pyprojectHook = pyprojectBootstrapHook;
    };
  }
