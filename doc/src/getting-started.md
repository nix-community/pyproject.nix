# Getting started

## Foreword

This documentation only helps you to get started with `pyproject.nix`.
As it's a toolkit with many use cases not every use case can be documented fully.

## Installation

### Flakes

[Nix Flakes](https://nix.dev/concepts/flakes) has many different opinionated ways to manage it's outputs.
This is the a minimal example of a Flake containing a pyproject.nix installation to show you the essence of how to install pyproject.nix.

```nix
{
  inputs.pyproject.url = "github:nix-community/pyproject.nix";
  inputs.pyproject.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, pyproject }: let
    inherit (nixpkgs) lib;

    # Loads pyproject.toml into a high-level project representation
    # Do you notice how this is not tied to any `system` attribute or package sets?
    # That is because `project` refers to a pure data representation.
    project = pyproject.lib.project.loadPyproject {
      # Read & unmarshal pyproject.toml
      pyproject = lib.importTOML ./pyproject.toml;
    };

    # This example is only using x86_64-linux
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    # We are using the default Python3 interpreter & package set
    python = pkgs.python3;

  in {

    # Create a development shell containing dependencies from `pyproject.toml`
    devShells.x86_64-linux.default = let
      # Returns a function that can be passed to `python.withPackages`
      arg = pyproject.lib.renderers.withPackages { inherit python project; };

      # Returns a wrapped environment (virtualenv like) with all our packages
      pythonEnv = python.withPackages arg;

    in pkgs.mkShell {
      packages = [ pythonEnv ];
    };

    # Build our package using `buildPythonPackage
    packages.x86_64-linux.default = let
      # Returns an attribute set that can be passed to `buildPythonPackage`.
      attrs = pyproject.lib.renderers.buildPythonPackage { inherit python project; };
    in python.pkgs.buildPythonPackage attrs;
  };
}
```
