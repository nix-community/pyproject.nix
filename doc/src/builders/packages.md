# packages

## Creating a base package set

``` nix
# Returns a scope with base packages.

pkgs.callPackage pyproject-nix.build.packages {
  python = interpreter;
}
```

## Overriding scope

See the [nixpkgs documentation](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.makeScope).
