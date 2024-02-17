# Integration tests are build tests i.e. construction of environment with
# assertions that imports works as expected.
{ pyproject
, pkgs
, lib
,
}:
let
  fixtures = import ./fixtures { inherit lib; };

  projects = {
    pdm-2_8_1 = {
      project = pyproject.lib.project.loadPyproject { pyproject = fixtures."pdm-2_8_1.toml"; };

      src = pkgs.fetchFromGitHub {
        owner = "pdm-project";
        repo = "pdm";
        rev = "2.8.1";
        sha256 = "sha256-/w74XmP1Che6BOE82klgzhwBx0nzAcw2aVyeWs+o3MA=";
      };

      buildPythonPackage.version = "2.8.1";

      # Assert these imports
      withPackages.imports = [
        "unearth"
        "findpython"
        "tomlkit"
        "installer"
        "pdm.backend" # PEP-518 build system
      ];
    };

    poetry-1_5_1 = {
      project = pyproject.lib.project.loadPoetryPyproject { pyproject = fixtures."poetry-1_5_1.toml"; };

      src = pkgs.fetchFromGitHub {
        owner = "python-poetry";
        repo = "poetry";
        rev = "1.5.1";
        sha256 = "sha256-1zqfGzSI5RDACSNcz0tLA4VKMFwE5uD/YqOkgpzg2nQ=";
      };

      buildPythonPackage.pipInstallFlags = "--no-deps";

      # Assert these imports
      withPackages.imports = [
        "tomlkit"
        "installer"
        "poetry.core" # PEP-518 build system
      ];
    };
  };

  python = pkgs.python3.override {
    self = python;
    # Poetry plugins aren't exposed in the Python set
    packageOverrides = _self: _super: (pkgs.poetry.override { python3 = python; }).plugins;
  };
in
# Construct withPackages environments and assert modules can be imported
lib.mapAttrs'
  (
    n: project: {
      name = "withPackages-${n}";
      value =
        let
          withFunc = pyproject.lib.renderers.withPackages {
            inherit python;
            inherit (project) project;
          };
          pythonEnv = python.withPackages withFunc;
        in
        pkgs.runCommand "withPackages-${n}" { } (lib.concatStringsSep "\n"
          (
            map (mod: "${pythonEnv.interpreter} -c 'import ${mod}'") project.withPackages.imports
          )
        + "\n"
        + "touch $out");
    }
  )
  projects
  // (
  lib.mapAttrs'
    (
      n: project: {
        name = "buildPythonPackage-${n}";
        value =
          let
            attrs = pyproject.lib.renderers.buildPythonPackage {
              inherit python;
              inherit (project) project;
            };
          in
          python.pkgs.buildPythonPackage (attrs
          // {
            inherit (project) src;
            # Add relax deps since we don't assert versions
            nativeBuildInputs = attrs.nativeBuildInputs or [ ] ++ [ python.pkgs.pythonRelaxDepsHook ];

            # HACK: Relax deps hook is not sufficient
            postPatch = ''
              substituteInPlace pyproject.toml \
                --replace '"unearth>=0.10.0"' '"unearth"' \
                --replace '"resolvelib>=1.0.1"' '"resolvelib"' \
                --replace 'poetry-core = "1.6.1"' 'poetry-core = "^1.5.0"' \
                --replace 'cachecontrol = { version = "^0.12.9", extras = ["filecache"] }' 'cachecontrol = { version = "*", extras = ["filecache"] }' \
                --replace 'virtualenv = "^20.22.0"' 'virtualenv = "*"'
            '';
          }
          // project.buildPythonPackage or { });
      }
    )
    projects
)
