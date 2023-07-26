{ pep599, ... }:
let
  inherit (pep599) manyLinuxTargetMachines;

in
{
  manyLinuxTargetMachines = {
    testSimple = {
      expr = manyLinuxTargetMachines."x86_64";
      expected = "x86_64";
    };
  };
}
