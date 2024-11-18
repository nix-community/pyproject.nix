# packages


`pyproject.nix`'s package set only contains builder code, and does not come with any Python packages pre-packaged.
It is not meant to be a general purpose Python set, but something for lock file consumers to build on top of.

## Creating a base package set

``` nix
# Returns a scope with base packages.
pkgs.callPackage pyproject-nix.build.packages {
  python = interpreter;
}
```

## Build system requirements

While the base package set doesn't contain any Python packages, `pyproject.nix` does provide pre-packaged build-system dependencies to compose with Python2nix tooling.
See [build-system-pkgs](https://github.com/pyproject-nix/build-system-pkgs).

## Overriding scope

See the [nixpkgs documentation](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.makeScope).
