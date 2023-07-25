{ lib, pep621, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) importTOML;
  inherit (pep621) parseDependencies parseRequiresPython;

  fixtures = mapAttrs (name: _: importTOML ./fixtures/${name}) (builtins.readDir ./fixtures);
  expected = mapAttrs (name: _: import ./expected/${name}) (builtins.readDir ./expected);

in
{
  parseDependencies = {
    testPandas = {
      expr = parseDependencies {
        pyproject = fixtures."pandas.toml";
      };
      expected = expected."parsedependencies-pandas.nix";
    };

    testPdm = {
      expr = parseDependencies {
        pyproject = fixtures."pdm.toml";
      };
      expected = expected."parsedependencies-pdm.nix";
    };
  };

  parseRequiresPython = {
    testPandas = {
      expr = parseRequiresPython fixtures."pandas.toml";
      expected = [{ op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 3 9 ]; }; }];
    };

    testPdm = {
      expr = parseRequiresPython fixtures."pdm.toml";
      expected = [{ op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 3 7 ]; }; }];
    };
  };
}
