{ lib, pyproject }:
let
  inherit (builtins) mapAttrs attrNames length substring stringLength;
  inherit (lib) mapAttrs';

  capitalise = s: lib.toUpper (substring 0 1 s) + (substring 1 (stringLength s) s);

  # Work with the tests as a tree
  # The attrpath is: module(file) -> symbol(function) -> test
in
lib.fix (self: {
  pep440 = import ./test_pep440.nix {
    inherit (pyproject) pep440;
    inherit lib;
  };

  pep491 = import ./test_pep491.nix {
    inherit (pyproject) pep491;
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
    (moduleName: mapAttrs' (sym: _: {
      name = "test" + capitalise sym;
      value = {
        expected = true;
        expr = self ? ${moduleName}.${sym} && length (attrNames self.${moduleName}.${sym}) >= 1;
      };
    }))
    pyproject;
})
