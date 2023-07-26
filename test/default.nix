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
      "pdm.backend" # PEP-518 build system
    ];
  };

  srcs = {
    "pdm-2_8_1.toml" = pkgs.fetchFromGitHub {
      owner = "pdm-project";
      repo = "pdm";
      rev = "2.8.1";
      sha256 = "sha256-/w74XmP1Che6BOE82klgzhwBx0nzAcw2aVyeWs+o3MA=";
    };
  };

  versions = {
    "pdm-2_8_1.toml" = "2.8.1";
  };

  python = pkgs.python3;

  stripTomlSuffix = s: builtins.head (builtins.match "^(.+).toml$" s);

in
# Construct withPackages environments and assert modules can be imported
(lib.mapAttrs'
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
)
  //
(
  lib.mapAttrs'
    (
      n: project:
        {
          name = "buildPythonPackage-${stripTomlSuffix n}";
          value =
            let
              attrs = pyproject.renderers.buildPythonPackage { inherit python project; };
            in
            python.pkgs.buildPythonPackage (attrs // {
              src = srcs.${n};
              # Add relax deps since we don't assert versions
              nativeBuildInputs = attrs.nativeBuildInputs or [ ]; # ++ [ python.pkgs.pythonRelaxDepsHook ];

              # HACK: Relax deps hook is not sufficient
              postPatch = ''
                substituteInPlace pyproject.toml \
                  --replace '"unearth>=0.10.0"' '"unearth"' \
                  --replace '"resolvelib>=1.0.1"' '"resolvelib"' \
              '';

            } // lib.optionalAttrs (!(attrs ? version)) {
              version = versions.${n};
            });
        }
    )
    projects
)
