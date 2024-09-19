{ lib, pyproject-nix, ... }:

let
  inherit (lib)
    optionalAttrs
    mapAttrs
    concatMap
    groupBy
    ;
  inherit (pyproject-nix.lib) pep621;

  # Make a dependency specification attrset from a list of dependencies
  mkSpec =
    dependencies: mapAttrs (_: concatMap (dep: dep.extras)) (groupBy (dep: dep.name) dependencies);

in
{

  mkDerivation =
    {
      project,
      environ,
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

      meta = pyproject-nix.lib.renderers.meta {
        inherit project;
      };
    }
    // optionalAttrs (pyproject.project ? name) { pname = pyproject.project.name; }
    // optionalAttrs (pyproject.project ? version) { inherit (pyproject.project) version; }
    // optionalAttrs (!pyproject.project ? version && pyproject.project ? name) {
      inherit (pyproject.project) name;
    }
    // optionalAttrs (project.projectRoot != null) { src = project.projectRoot; };
}
