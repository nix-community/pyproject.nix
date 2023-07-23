# Hacking

## Getting started

To start hacking run `nix develop -c run` to run the project with a file watcher running the unit test suite.

## Project structure & testing

All Nix code lives in `lib/`. Each file has an implementation and a test suite.
The attribute path to a an attribute `parseVersion` in `lib/pep440.nix` would be `lib.pep440.parseVersion`.

A function in `lib/test.nix` maps over the public interface of the library and the test suite to generate coverage tests, ensuring that every exported symbol has at least one test covering it.

## Running tests

- Run the entire test suite
  `$ nix-unit --flake .#libTests`

- Run tests for an individual function
  `$ nix-unit --flake .#libTests.pep440.parseVersion`

## Formatter

Before submitting a PR format the code with `nix fmt` and ensure Flake checks pass with `nix flake check`.
