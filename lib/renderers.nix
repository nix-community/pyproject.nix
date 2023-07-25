{ lib
, filter
, pep508
, pep621
, pypa
, ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib) optionalAttrs flatten;

  getBuildSystems = project: map (dep: pypa.normalizePackageName dep.name) project.build-systems;

in
lib.fix (_self: {
  /*
    Renders a project as an argument that can be passed to withPackages

    Evaluates PEP-508 environment markers to select correct dependencies for the platform but does not validate version constraints.
    For validation see `lib.validators`.

    Type: withPackages :: AttrSet -> lambda

    Example:
    # withPackages (lib.project.loadPyproject { ... })
      «lambda @ «string»:1:1»
    */
  withPackages =
    {
      # Project metadata as returned by `lib.project.loadPyproject`
      project
    , # Python derivation
      python
    , # Python extras (optionals) to enable
      extras ? [ ]
    ,
    }:
    let
      filteredDeps = filter.filterDependencies {
        inherit (project) dependencies;
        environ = pep508.mkEnviron python;
        inherit extras;
      };
      namedDeps = pep621.getDependenciesNamesNormalized filteredDeps;
      flatDeps = flatten ([ namedDeps.dependencies ] ++ attrValues namedDeps.extras) ++ getBuildSystems project;
    in
    ps: map (dep: ps.${dep}) flatDeps;

  /*
    Renders a project as an argument that can be passed to buildPythonPackage/buildPythonApplication.

    Evaluates PEP-508 environment markers to select correct dependencies for the platform but does not validate version constraints.
    For validation see `lib.validators`.

    Type: withPackages :: AttrSet -> AttrSet

    Example:
      # withPackages (lib.project.loadPyproject { ... })
      { pname = "blinker"; version = "1.3.3.7"; propagatedBuildInputs = [ ]; }
    */
  buildPythonPackage =
    {
      # Project metadata as returned by `lib.project.loadPyproject`
      project
    , # Python derivation
      python
    , # Python extras (optionals) to enable
      extras ? [ ]
    , # Map a Python extras group name to a Nix attribute set.
      # This is intended to be used with optionals such as test dependencies that you might
      # want to add to checkInputs instead of propagatedBuildInputs
      extrasAttrMappings ? { }
    ,
    }:
    let
      filteredDeps = filter.filterDependencies {
        inherit (project) dependencies;
        environ = pep508.mkEnviron python;
        inherit extras;
      };

      namedDeps = pep621.getDependenciesNamesNormalized filteredDeps;

      attrs = builtins.foldl'
        (acc: group:
          let
            attr = extrasAttrMappings.${group} or "propagatedBuildInputs";
          in
          acc // {
            ${attr} = acc.${attr} or [ ] ++ map (dep: python.pkgs.${dep}) namedDeps.extras.${group};
          })
        {
          pname = project.pyproject.project.name;
          propagatedBuildInputs = map (dep: python.pkgs.${dep}) namedDeps.dependencies;
          nativeBuildInputs = getBuildSystems project;
        }
        (builtins.attrNames namedDeps.extras);

    in
    attrs // optionalAttrs (project.pyproject.project ? version) {
      inherit (project.pyproject.project) version;
    };
})
