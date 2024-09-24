{ lib, pyproject-nix, ... }:

let
  inherit (lib)
    optionalAttrs
    mapAttrs
    concatMap
    groupBy
    ;
  inherit (pyproject-nix.lib.renderers) meta;
  inherit (pyproject-nix.lib) pep621;

  # Make a dependency specification attrset from a list of dependencies
  mkSpec =
    dependencies: mapAttrs (_: concatMap (dep: dep.extras)) (groupBy (dep: dep.name) dependencies);

  fallbackBuildSystems = map pyproject-nix.lib.pep508.parseString [
    "setuptools"
    "wheel"
  ];

in
{

  /*
    Renders a project as an argument that can be passed to stdenv.mkDerivation.

    Evaluates PEP-508 environment markers to select correct dependencies for the platform but does not validate version constraints.

    Type: mkDerivation :: AttrSet -> AttrSet
  */
  mkDerivation =
    {
      # Loaded pyproject.nix project
      project,
      # PEP-508 environment
      environ,
      # Extras to enable (markers only, `optional-dependencies` are not enabled by default)
      extras ? [ ],
    }:
    let
      inherit (project) pyproject;

      filteredDeps = pep621.filterDependenciesByEnviron environ extras project.dependencies;

    in
    { pyprojectHook, resolveBuildSystem }:
    {
      passthru = {
        dependencies = mkSpec filteredDeps.dependencies;
        optional-dependencies = mapAttrs (_: mkSpec) filteredDeps.extras;
      };

      nativeBuildInputs = [
        pyprojectHook
      ] ++ resolveBuildSystem (mkSpec filteredDeps.build-systems);

      meta = meta {
        inherit project;
      };
    }
    // optionalAttrs (pyproject.project ? name) { pname = pyproject.project.name; }
    // optionalAttrs (pyproject.project ? version) { inherit (pyproject.project) version; }
    // optionalAttrs (!pyproject.project ? version && pyproject.project ? name) {
      inherit (pyproject.project) name;
    }
    // optionalAttrs (project.projectRoot != null) { src = project.projectRoot; };

  /*
    Renders a project as an argument that can be passed to stdenv.mkDerivation.

    Evaluates PEP-508 environment markers to select correct dependencies for the platform but does not validate version constraints.

    Type: mkDerivation :: AttrSet -> AttrSet
  */
  mkDerivationEditable =
    {
      # Loaded pyproject.nix project
      project,
      # PEP-508 environment
      environ,
      # Extras to enable (markers only, `optional-dependencies` are not enabled by default)
      extras ? [ ],
      # Editable root directory as a string
      root ? toString (
        # Prefer src layout if available
        if lib.pathExists (project.projectRoot + "/src") then
          (project.projectRoot + "/src")
        # Otherwise assume project root is editable root
        else
          project.projectRoot
      ),
    }:
    let
      filteredDeps = pep621.filterDependenciesByEnviron environ extras project.dependencies;
    in
    {
      python,
      pyprojectHook,
      pythonPackagesBuildHost,
      resolveBuildSystem,
    }:
    let
      project' = project.pyproject.project;
      pname = project'.name;

      # Synthetic pyproject.toml
      #
      # We don't use the provided build-system to build an editable package, we use hatchling.
      pyproject = {
        # PEP-621 project table
        project =
          {
            # Both name and version are required.
            inherit (project') name version;
          }
          // optionalAttrs (project' ? dependencies) {
            inherit (project') dependencies;
          }
          // optionalAttrs (project' ? optional-dependencies) {
            inherit (project') optional-dependencies;
          }
          // optionalAttrs (project' ? scripts) {
            inherit (project') scripts;
          }
          // optionalAttrs (project' ? gui-scripts) {
            inherit (project') gui-scripts;
          }
          // optionalAttrs (project' ? entry-points) {
            inherit (project') entry-points;
          };

        # Allow empty package
        tool.hatch.build.targets.wheel.bypass-selection = true;

        # Include our editable pointer file in build
        tool.hatch.build.targets.wheel.force-include."_${pname}.pth" = "_${pname}.pth";

        # Build editable package using hatchling
        build-system = {
          requires = [ "hatchling" ];
          build-backend = "hatchling.build";
        };
      };
    in
    {
      inherit pname;

      passthru = {
        dependencies = mkSpec (
          filteredDeps.dependencies
          ++ (
            if (filteredDeps.build-systems != [ ]) then filteredDeps.build-systems else fallbackBuildSystems
          )
        );
        optional-dependencies = mapAttrs (_: mkSpec) filteredDeps.extras;
      };

      # Convert created JSON format pyproject.toml into TOML and include a generated pth file
      unpackPhase = ''
        env PYTHONPATH=${pythonPackagesBuildHost.tomli-w}/${python.sitePackages} python -c "import json, tomli_w; print(tomli_w.dumps(json.load(open('$pyprojectContentsPath'))))" > pyproject.toml
        echo 'import os.path, sys; sys.path.insert(0, os.path.expandvars("${root}"))' > _${pname}.pth
      '';

      nativeBuildInputs =
        [
          pyprojectHook
        ]
        ++ resolveBuildSystem {
          hatchling = [ ];
        };

      pyprojectContents = builtins.toJSON pyproject;
      passAsFile = [ "pyprojectContents" ];

      meta = meta {
        inherit project;
      };
    }
    // optionalAttrs (project' ? version) {
      inherit (project') version;
    }
    // optionalAttrs (!project' ? version) {
      name = pname;
    };

}
