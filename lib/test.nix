{ lib, pyproject }:
let
  inherit (builtins) mapAttrs attrNames length;

  # Work with the tests as a tree internally
  # The attrpath is: module(file) -> symbol(function) -> test
  tests = lib.fix (self: {
    pep440 = import ./test_pep440.nix {
      inherit (pyproject) pep440;
      inherit lib;
    };

    pep508 = import ./test_pep508.nix {
      inherit (pyproject) pep508;
      inherit lib;
    };

    # Yo dawg, I heard you like tests...
    #
    # Check that all exported modules are covered by a test suite with at least one test.
    coverage = mapAttrs
      (moduleName: mapAttrs (sym: _: {
        expected = true;
        expr = self ? ${moduleName}.${sym} && length (attrNames self.${moduleName}.${sym}) >= 1;
      }))
      pyproject;
  });

in
# Flatten the tree into a tree of test
lib.listToAttrs (lib.flatten (lib.flatten (
  lib.mapAttrsToList
    (moduleName: lib.mapAttrsToList (sym: tests: map
      (testName: {
        name = "${moduleName}/${sym}/${testName}";
        value = tests.${testName};
      })
      (lib.attrNames tests)))
    tests
)))
