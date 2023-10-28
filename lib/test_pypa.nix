{ lib, pypa, ... }:
let
  inherit (pypa) normalizePackageName parsePythonTag parseABITag;
  inherit (lib) mapAttrs';

in

{
  normalizePackageName = mapAttrs'
    (n: _: {
      name = "testNormalize${n}";
      value = { expr = normalizePackageName n; expected = "friendly-bard"; };
    })
    {
      "friendly-bard" = { };
      "Friendly-Bard" = { };
      "FRIENDLY-BARD" = { };
      "friendly.bard" = { };
      "friendly_bard" = { };
      "friendly--bard" = { };
      "FrIeNdLy-._.-bArD" = { };
    };

  parsePythonTag = {
    testWithFlags = {
      expr = parsePythonTag "cp37";
      expected = {
        implementation = "cpython";
        version = "37";
      };
    };
  };

  parseABITag = {
    testWithFlags = {
      expr = parseABITag "cp37dmu";
      expected = {
        flags = [ "d" "m" "u" ];
        implementation = "cpython";
        version = "37";
      };
    };
  };
}
