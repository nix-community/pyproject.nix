{
  lib,
  pep440,
  pep508,
  pep518,
  pypa,
  ...
}:
let
  inherit (builtins)
    mapAttrs
    foldl'
    split
    filter
    elem
    ;
  inherit (lib)
    isString
    filterAttrs
    fix
    nameValuePair
    mapAttrs'
    ;

  splitAttrPath = path: filter isString (split "\\." path);
  getAttrPath = path: lib.attrByPath (splitAttrPath path);

in
fix (self: {
  /*
    Parse dependencies from pyproject.toml.

    Type: parseDependencies :: AttrSet -> AttrSet

    Example:
      # parseDependencies {
      #
      #   pyproject = (lib.importTOML ./pyproject.toml);
      #   # Don't just look at `project.optional-dependencies` for groups, also look at these:
      #   extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
      # }
      {
        dependencies = [ ];  # List of parsed PEP-508 strings (lib.pep508.parseString)
        extras = {
          dev = [ ];  # List of parsed PEP-508 strings (lib.pep508.parseString)
        };
        build-systems = [ ];  # PEP-518 build-systems (List of parsed PEP-508 strings)
      }
  */
  parseDependencies =
    {
      pyproject,
      extrasAttrPaths ? [ ],
      extrasListPaths ? { },
    }:
    let
      # Fold extras from all considered attributes into one set
      extras' =
        foldl' (acc: attr: acc // getAttrPath attr { } pyproject) (pyproject.project.optional-dependencies
          or { }
        ) extrasAttrPaths
        // mapAttrs' (path: attr: nameValuePair attr (getAttrPath path [ ] pyproject)) extrasListPaths;
    in
    {
      dependencies = map pep508.parseString (pyproject.project.dependencies or [ ]);
      extras = mapAttrs (_: map pep508.parseString) extras';
      build-systems = pep518.parseBuildSystems pyproject;
    };

  /*
    Parse project.python-requires from pyproject.toml

    Type: parseRequiresPython :: AttrSet -> list

    Example:
      #  parseRequiresPython (lib.importTOML ./pyproject.toml)
      [ ]  # List of conditions as returned by `lib.pep440.parseVersionCond`
  */
  parseRequiresPython = pyproject: pep440.parseVersionConds (pyproject.project.requires-python or "");

  /*
    Takes a dependency structure as returned by `lib.pep621.parseDependencies` and transforms it into
    a structure with it's package names.

    Type: getDependenciesNames :: AttrSet -> AttrSet

    Example:
      # getDependenciesNames (pep621.parseDependencies { pyproject = (lib.importTOML ./pyproject.toml); })
      {
        dependencies = [ "requests" ];
        extras = {
          dev = [ "pytest" ];
        };
        build-systems = [ "poetry-core" ];
      }
  */
  getDependenciesNames =
    let
      normalize = pypa.normalizePackageName;
      getNames = map (dep: normalize dep.name);
    in
    dependencies: {
      dependencies = getNames dependencies.dependencies;
      extras = mapAttrs (_: getNames) dependencies.extras;
      build-systems = getNames dependencies.build-systems;
    };

  /*
    Filter dependencies not relevant for this environment.

    Type: filterDependenciesByEnviron :: AttrSet -> AttrSet -> AttrSet

    Example:
      # filterDependenciesByEnviron (lib.pep508.mkEnviron pkgs.python3) (lib.pep621.parseDependencies (lib.importTOML ./pyproject.toml))
      { }  # Structure omitted in docs
  */
  filterDependenciesByEnviron =
    # Environ as created by `lib.pep508.mkEnviron`.
    environ:
    # Extras as a list of strings
    extras:
    # Dependencies as parsed by `lib.pep621.parseDependencies`.
    dependencies:
    (
      let
        environ' = environ // {
          extra = {
            type = "extra";
            value = extras;
          };
        };

        filterList = filter (dep: dep.markers == null || pep508.evalMarkers environ' dep.markers);
      in
      {
        dependencies = filterList dependencies.dependencies;
        extras = mapAttrs (_: filterList) dependencies.extras;
        build-systems = filterList dependencies.build-systems;
      }
    );

  /*
    Filter dependencies by their extras groups.

    Type: filterDependenciesByExtras :: list[string] -> AttrSet -> AttrSet

    Example:
      # filterDependenciesByExtras [ "dev" ] (lib.pep621.parseDependencies (lib.importTOML ./pyproject.toml))
      { }  # Structure omitted in docs
  */
  filterDependenciesByExtras =
    # Extras groups as a list of strings.
    extras:
    # Dependencies as parsed by `lib.pep621.parseDependencies`.
    dependencies:
    dependencies // { extras = filterAttrs (group: _: elem group extras) dependencies.extras; };

  /*
    Aggregate of `filterDependencies` & `filterDependenciesByExtras`

    Type: filterDependencies :: AttrSet -> AttrSet

    Example:
      # filterDependencies {
      #   dependencies = lib.pep621.parseDependencies (lib.importTOML ./pyproject.toml);
      #   environ = lib.pep508.mkEnviron pkgs.python;
      #   extras = [ "dev" ];
      # }
      { }  # Structure omitted in docs
  */
  filterDependencies =
    {
      # Dependencies as parsed by `lib.pep621.parseDependencies`
      dependencies,
      # Environ as created by `lib.pep508.mkEnviron`
      environ,
      # Extras as a list of strings
      extras ? [ ],
    }:
    self.filterDependenciesByEnviron environ extras (
      self.filterDependenciesByExtras extras dependencies
    );
})
