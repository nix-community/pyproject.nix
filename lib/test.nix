{ lib, pyproject }:
let
  inherit (builtins) mapAttrs attrNames length substring stringLength;
  inherit (lib) mapAttrs';

  capitalise = s: lib.toUpper (substring 0 1 s) + (substring 1 (stringLength s) s);

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
lib.fix (self: {
  pypa = importTests ./test_pypa.nix;
  filter = importTests ./test_filter.nix;
  project = importTests ./test_project.nix;

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
