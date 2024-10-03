{
  pyproject-nix,
  lib,
  pkgs,
}:

{
  renderers = import ./test_renderers.nix { inherit pkgs lib pyproject-nix; };
}
