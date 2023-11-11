# Introduction

## Foreword

This documentation only helps you to get started with `pyproject.nix`.
As it's a toolkit with many use cases not every use case can be documented fully.

This documentation is centered around packaging Python applications.
For other use cases see the reference documentation.

## Concepts

`pyproject.nix` introduces a few high level abstract concepts.
The best way to get started is to understand these concepts and how they fit together.

### [Project](./lib/project.md)

A `project` attrset is a high-level representation of a project that includes:

- The parsed `pyproject.toml` file
- Parsed dependencies
- Project root directory

It can can be loaded from many different sources:

- PEP-621 `pyproject.toml`
- PEP-621 `pyproject.toml` with PDM extensions
- Poetry `pyproject.toml`
- `requirements.txt`

### [Validators](./lib/validators.md)

Validators work on dependency constraints as defined in a `project` and offers validation for them.
This can be useful to check that a package set is compilant with the specification.

### [Renderers](./lib/renderers.md)

A `renderer` takes a `project` together with a Python interpreter derivation and renders it into a form understood by various pieces of nixpkgs Python infrastructure.

For example: The `buildPythonPackage` renderer returns an attribute set that can be passed to either nixpkgs function `buildPythonPackage` or `buildPythonApplication`.

There might be information missing from what a renderer returned depending on what can be computed from the `project`.
If any attributes are missing you can manually merge your own attribute set with what the renderer returned.

## Tying it together

For a concrete example use see [Use cases -> pyproject.toml](./use-cases/pyproject.md).
