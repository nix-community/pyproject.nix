{ lib, pep508, ... }:
let
  inherit (builtins) elem filter mapAttrs;
  inherit (lib) filterAttrs;

  filterList = environ: filter (dep: dep.markers == null || pep508.evalMarkers environ dep.markers);

in

lib.fix (self: {
  /* Filter dependencies not relevant for this environment.

     Type: filterDependenciesByEnviron :: AttrSet -> AttrSet -> AttrSet

     Example:
       # filterDependenciesByEnviron (lib.pep508.mkEnviron pkgs.python3) (lib.pep621.parseDependencies (lib.importTOML ./pyproject.toml))
       { }  # Structure omitted in docs
  */
  filterDependenciesByEnviron =
    # Environ as created by `lib.pep508.mkEnviron`.
    environ:
    # Dependencies as parsed by `lib.pep621.parseDependencies`.
    dependencies:
    {
      dependencies = filterList environ dependencies.dependencies;
      extras = mapAttrs (_: filterList environ) dependencies.extras;
      build-systems = filterList environ dependencies.build-systems;
    };

  /* Filter dependencies by their extras groups.

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
    dependencies // {
      extras = filterAttrs (group: _: elem group extras) dependencies.extras;
    };

  /* Aggregate of `filterDependencies` & `filterDependenciesByExtras`

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
      dependencies
    , # Environ as created by `lib.pep508.mkEnviron`
      environ
    , # Extras as a list of strings
      extras ? [ ]
    ,
    }: self.filterDependenciesByEnviron environ (self.filterDependenciesByExtras extras dependencies);
})
