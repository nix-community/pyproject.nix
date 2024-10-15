{ lib }:
{
  lib = import ./lib { inherit lib; };
  build = import ./build { inherit lib; };
}
