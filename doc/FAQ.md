# FAQ

- How does package name mapping from Python to Nixpkgs work?

Package names are normalized according to the [PyPA normalization specification](https://packaging.python.org/en/latest/specifications/name-normalization/#normalization).
Nixpkgs also uses the same normalization [but has some legacy package names](https://github.com/NixOS/nixpkgs/issues/245383) that do not follow normalization guidelines.

- What do you do with `dynamic` attributes?

Pyproject.nix makes no attempt at parsing dynamic fields as it does not have the required knowledge to infer these.

When using the `withPackages` renderer most fields that may be dynamic are not even relevant and won't cause issues.
At other times, like when using the `buildPythonPackage` renderer problems occur as there is no way for the renderer to create the version attribute.

```nix
let
  project = pyproject.project.loadPyproject { pyproject = lib.importTOML ./pyproject.toml; };
  python = pkgs.python3;
  attrs = pyproject.renderers.withPackages { inherit python project; };
in python.pkgs.buildPythonPackage(attrs)
```

Will result in an error from `buildPythonpackage` because `version` is missing:

```
error: attribute 'version' missing

at /nix/store/gna8i238i3nnz6cizcayyfyfdzn28la5-nixpkgs/pkgs/development/interpreters/python/mk-python-derivation.nix:31:28:

    30|
    31| { name ? "${attrs.pname}-${attrs.version}"
      |                            ^
    32|
```

In these cases you can manually add attributes to the attribute set returned by the renderer:

```nix
let
  project = pyproject.project.loadPyproject { pyproject = lib.importTOML ./pyproject.toml; };
  python = pkgs.python3;
  attrs = pyproject.renderers.withPackages { inherit python project; };
in python.pkgs.buildPythonPackage(attrs // {
  version = "1.0";  # Not dynamically inferred
})
```
