{ lib, pep599, ... }:
let
  inherit (pep599) manyLinuxTargetMachines;

in
lib.fix (_self: {
  manyLinuxTargetMachines = {
    testSimple = {
      expr = manyLinuxTargetMachines."x86_64";
      expected = "x86_64";
    };
  };
})
