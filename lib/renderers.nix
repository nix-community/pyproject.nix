{ lib
, filter
, pep508
, pep621
, ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib) optionalAttrs flatten;
in
lib.fix (_self: {
  /*
    Renders a project as an argument that can be passed to withPackages

    Type: withPackages :: AttrSet -> lambda

    Example:
    # withPackages (lib.project.loadPyproject { ... })
      {
        dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
        build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
        pyproject = { }; # The unmarshaled contents of pyproject.toml
      }
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
      flatDeps = flatten ([ namedDeps.dependencies ] ++ attrValues namedDeps.extras);
    in
    ps: map (dep: ps.${dep}) flatDeps;

  /*
    Renders a project as an argument that can be passed to buildPythonPackage/buildPythonApplication

    Type: withPackages :: AttrSet -> lambda

    Example:
    # withPackages (lib.project.loadPyproject { ... })
      {
        dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
        build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
        pyproject = { }; # The unmarshaled contents of pyproject.toml
      }
    */
  buildPythonPackage =
    {
      # Project metadata as returned by `lib.project.loadPyproject`
      project
    , # Pytho derivation
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
        }
        (builtins.attrNames namedDeps.extras);

    in
    attrs // optionalAttrs (project.pyproject.project ? version) {
      inherit (project.pyproject.project) version;
    };
})
