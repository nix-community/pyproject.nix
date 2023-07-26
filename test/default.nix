# Integration tests are build tests i.e. construction of environment with
# assertions that imports works as expected.

{ pyproject, pkgs, lib }:
let
  fixtures = import ./fixtures { inherit lib; };

  projects = lib.mapAttrs
    (_: pyprojectTOML: pyproject.project.loadPyproject {
      pyproject = pyprojectTOML;
    })
    fixtures;

  assertImports = {
    "pdm-2_8_1.toml" = [
      "unearth"
      "findpython"
      "tomlkit"
      "installer"
    ];
  };

  python = pkgs.python3;

  stripTomlSuffix = s: builtins.head (builtins.match "^(.+).toml$" s);

in
# Construct withPackages environments and assert modules can be imported
lib.mapAttrs'
  (
    n: project:
    {
      name = "withPackages-${stripTomlSuffix n}";
      value =
        let
          withFunc = pyproject.renderers.withPackages { inherit python project; };
          pythonEnv = python.withPackages withFunc;
        in
        pkgs.runCommand "withPackages-${n}" { } (lib.concatStringsSep "\n"
          (
            map (mod: "${pythonEnv.interpreter} -c 'import ${mod}'") assertImports.${n}
          ) + "\n" + "touch $out");
    }
  )
  projects
