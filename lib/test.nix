{ lib, pyproject }:
let
  inherit (builtins) mapAttrs attrNames length;

in
lib.fix (self: {
  pep508 = import ./test_pep508.nix {
    inherit (pyproject) pep508;
    inherit lib;
  };

  # Yo dawg, I heard you like tests...
  #
  # Check that all exported modules are covered by a test suite with at least one test.
  coverage = mapAttrs
    (moduleName: mapAttrs (sym: _: {
      covered = {
        expected = true;
        expr = length (attrNames self.${moduleName}.${sym}) >= 1;
      };
    }))
    pyproject;
})
