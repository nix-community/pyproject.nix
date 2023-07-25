{ lib, pep440, pep508, pypa, ... }:
let
  inherit (builtins) mapAttrs foldl' split filter;
  inherit (lib) isString;

  splitAttrPath = path: filter isString (split "\\." path);
  getAttrPath = path: lib.getAttrFromPath (splitAttrPath path);

in
lib.fix (_self: {
  /* Parse dependencies from pyproject.toml.

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
       }
  */
  parseDependencies = { pyproject, extrasAttrPaths ? [ ] }:
    let
      # Fold extras from all considered attributes into one set
      extras' = foldl' (acc: attr: acc // getAttrPath attr pyproject) (pyproject.project.optional-dependencies or { }) extrasAttrPaths;
    in
    {
      dependencies = map pep508.parseString (pyproject.project.dependencies or [ ]);
      extras = mapAttrs (_: map pep508.parseString) extras';
    };

  /* Parse project.python-requires from pyproject.toml

     Type: parseRequiresPython :: AttrSet -> list

     Example:
       #  parseRequiresPython (lib.importTOML ./pyproject.toml)
       [ ]  # List of conditions as returned by `lib.pep440.parseVersionCond`
  */
  parseRequiresPython = pyproject: map pep440.parseVersionCond (filter isString (split "," (pyproject.project.requires-python or "")));

  /* Takes a dependency structure as returned by `lib.pep621.parseDependencies` and transforms it into
     a structure with it's normalized names as normalized by `lib.pypa.normalizePackageName`.

     Type: getDependenciesNamesNormalized :: AttrSet -> AttrSet

     Example:
       # getDependenciesNamesNormalized (pep621.parseDependencies { pyproject = (lib.importTOML ./pyproject.toml); })
       {
         dependencies = [ "requests" ];
         extras = {
           dev = [ "pytest" ];
         };
       }
  */
  getDependenciesNamesNormalized =
    let
      normalizeList = map (dep: pypa.normalizePackageName dep.name);
    in
    dependencies: {
      dependencies = normalizeList dependencies.dependencies;
      extras = mapAttrs (_: normalizeList) dependencies.extras;
    };
})
