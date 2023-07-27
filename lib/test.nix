{ lib, pyproject, pkgs }:
let
  inherit (builtins) mapAttrs attrNames length substring stringLength;
  inherit (lib) mapAttrs' toUpper fix;

  capitalise = s: toUpper (substring 0 1 s) + (substring 1 (stringLength s) s);

  mocks =
    let
      # Mock python derivations so we don't have to keep a pkgs reference
      mkPython =
        { pname ? "python"
        , version
        , pythonVersion ? version
        , implementation ? "cpython"
        , isLinux ? false
        , isDarwin ? false
        ,
        }: {
          inherit pname version;
          passthru = {
            inherit pythonVersion implementation;
          };
          # Generate a dummy package set based on the real python one
          # Note that inheriting from nixpkgs like this _will_ break tests
          # when updating nixpkgs.
          #
          # When that happens add another override to the attrset below.
          pkgs = mapAttrs
            (_n: drv: {
              inherit (drv) pname version;
            })
            pkgs.python3.pkgs // {

            tox-pdm = {
              pname = "tox-pdm";
              version = "0.1.0";
            };

            resolvelib = {
              pname = "resolvelib";
              version = "0.5.5";
            };

            oldest-supported-numpy = {
              pname = "oldest-supported-numpy";
              version = "1.0.0";
            };

            unearth = {
              pname = "unearth";
              version = "0.9.1";
            };

            pre-commit = {
              pname = "pre-commit";
              version = "3.3.3";
            };

            poetry-plugin-export = {
              pname = "poetry-plugin-export";
              version = "1.4.0";
            };
          };
          stdenv = {
            inherit isLinux isDarwin;
            targetPlatform.parsed.cpu.name = "x86_64";
          };
        };
    in
    {
      cpythonLinux38 = mkPython {
        version = "3.8.2";
        pythonVersion = "3.8";
        isLinux = true;
      };

      cpythonDarwin311 = mkPython {
        version = "3.11.4";
        pythonVersion = "3.11";
        isDarwin = true;
      };

      pypy39Linux = mkPython {
        pname = "pypy";
        version = "7.3.11";
        pythonVersion = "3.9";
        isLinux = true;
        implementation = "pypy";
      };
    };

  importTests = path: import path (pyproject // {
    inherit lib mocks;
    fixtures = import ./fixtures;
  });

in
# Work with the tests as a tree
  # The attrpath is: module(file) -> symbol(function) -> test
fix (self: {
  pypa = importTests ./test_pypa.nix;
  project = importTests ./test_project.nix;
  renderers = importTests ./test_renderers.nix;
  validators = importTests ./test_validators.nix;
  poetry = importTests ./test_poetry.nix;

  pep427 = importTests ./test_pep427.nix;
  pep440 = importTests ./test_pep440.nix;
  pep508 = importTests ./test_pep508.nix;
  pep518 = importTests ./test_pep518.nix;
  pep599 = importTests ./test_pep599.nix;
  pep600 = importTests ./test_pep600.nix;
  pep621 = importTests ./test_pep621;

  # Yo dawg, I heard you like tests...
  #
  # Check that all exported modules are covered by a test suite with at least one test.
  coverage = mapAttrs
    (moduleName: mapAttrs' (sym: _: {
      name = "test" + capitalise sym;
      value = {
        expected = true;
        expr = self ? ${moduleName}.${sym} && length (attrNames self.${moduleName}.${sym}) >= 1;
      };
    }))
    pyproject;
})
