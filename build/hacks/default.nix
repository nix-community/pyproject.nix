{ pkgs, lib }:

let
  inherit (pkgs) stdenv python3;
  inherit (lib) isDerivation isAttrs;

in
{
  /**
    Use a package output built by Nixpkgs Python infrastructure.

    Adapts a package by:
    - Stripping dependency propagation
    - Throwing away shell script wrapping
    - Filtering out sys.path dependency injection

    This adaptation will of course break anything depending on other packages by `$PATH`, as these are injected by wrappers.

    # Example

    ```nix
    nixpkgsPrebuilt {
      from = pkgs.python3Packages.torchWithoutCuda;
      prev = prev.torch;
    }
    =>
    «derivation /nix/store/3864g3951bkbkq5nrld5yd8jxq7ss72y-torch-2.4.1.drv»
    ```

    # Type

    ```
    nixpkgsPrebuilt :: AttrSet -> derivation
    ```

    # Arguments

    from
    : Prebuilt package to transform output from

    prev
    : Previous pyproject.nix package to take passthru from
  */
  nixpkgsPrebuilt =
    {
      # Take build results from package
      # Example: pkgs.python3Packages.torchWithoutCuda
      from,
      # Previous package to take passthru from
      prev,
    }:
    assert isDerivation from;
    assert isAttrs prev; # Allow prev to be a simple attrset
    stdenv.mkDerivation {
      inherit (from) pname version;
      inherit (prev) passthru;

      nativeBuildInputs = [
        python3
      ];

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        python3 ${./write-nixpkgs-prebuilt.py} --store ${builtins.storeDir} ${from} "$out"
      '';
    };
}
