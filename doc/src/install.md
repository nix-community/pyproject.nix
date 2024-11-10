# Installation

## Classic Nix

Documentation examples in `pyproject.nix` are using Flakes for the convenience of grouping multiple concepts into a single file.

You can just as easily import `pyproject.nix` without using Flakes:
``` nix
let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  pyproject-nix = import (builtins.fetchGit {
    url = "https://github.com/nix-community/pyproject.nix.git";
  }) {
    inherit lib;
  };

in ...
```

## Flakes

See [use-cases/pyproject.toml](use-cases/pyproject.md).
