{ lib, pypa, ... }:
let
  inherit (pypa) normalizePackageName;
  inherit (lib) mapAttrs';

in

lib.fix (_self: {
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
})
