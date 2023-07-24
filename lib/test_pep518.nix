{ lib, pep518, ... }:
let
  inherit (pep518) parseBuildSystems;

in
lib.fix (_self: {
  parseBuildSystems = {
    testSimple = {
      expr = parseBuildSystems {
        build-system.requires = [ "blinker" ];
      };
      expected = [
        {
          name = "blinker";
          conditions = [ ];
          extras = [ ];
          markers = null;
          url = null;
        }
      ];
    };
  };
})
