# packages

`pyproject.nix`'s package set is much smaller and more narrow in scope than nixpkgs.
It's purpose is only to package [build-system](https://peps.python.org/pep-0518/) dependencies, which are missing from Python package manager lock files, so needs to be supplemented from elsewhere.

It is not meant to be a general purpose Python set, only something for lock file consumers to build on top of.

## Creating a base package set

``` nix
# Returns a scope with base packages.
pkgs.callPackage pyproject-nix.build.packages {
  python = interpreter;
}
```

## Overriding scope

See the [nixpkgs documentation](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.makeScope).
