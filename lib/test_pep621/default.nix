{ lib, pep621, ... }:
let
  inherit (builtins) head match readDir;
  inherit (pep621) parsePyproject;

in
{
  parsePyproject =
    let
      expected = lib.mapAttrs' (n: _v: { name = head (match "^(.+)\.nix$" n); value = import ./expected/${n}; }) (readDir ./expected);
    in
    lib.mapAttrs'
      (n: _v:
        let
          name = builtins.head (builtins.match "^(.+)\.toml$" n);
        in
        {
          name = "testFixture${name}";
          value = {
            expr = parsePyproject ./fixtures/${n};
            expected = expected.${name};
          };
        })
      (builtins.readDir ./fixtures);
}
