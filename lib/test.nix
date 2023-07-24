{ lib, pyproject }:
let
  inherit (builtins) mapAttrs attrNames length substring stringLength;
  inherit (lib) mapAttrs';

  capitalise = s: lib.toUpper (substring 0 1 s) + (substring 1 (stringLength s) s);

  importTests = path: import path (pyproject // { inherit lib; });

in
# Work with the tests as a tree
  # The attrpath is: module(file) -> symbol(function) -> test
lib.fix (self: {
  pep440 = importTests ./test_pep440.nix;
  pep491 = importTests ./test_pep491.nix;
  pep508 = importTests ./test_pep508.nix;
  pep599 = importTests ./test_pep599.nix;
  pep600 = importTests ./test_pep600.nix;

  # Yo dawg, I heard you like tests...
  #
  # Check that all exported modules are covered by a test suite with at least one test.
  coverage = mapAttrs
    (moduleName: mapAttrs' (sym: _: {
      name = "test" + capitalise sym;
      value = {
        expected = true;
        expr = self ? ${moduleName}.${sym} && length (attrNames self.${moduleName}.${sym}) >= 1;
      };
    }))
    pyproject;
})
