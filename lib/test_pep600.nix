{ lib, pep600, ... }:
let
  inherit (pep600) normalizeTag;

in
lib.fix (_self: {
  normalizeTag = {
    testSimple = {
      expr = normalizeTag "manylinux1_x86_64";
      expected = "manylinux_2_5_x86_64";
    };

    testNoMatch = {
      expr = normalizeTag "nomanylinux1_x86_64";
      expected = "nomanylinux1_x86_64";
    };
  };
})
