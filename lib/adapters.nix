{ lib, ... }:

lib.fix (_self: {

  /* Create an attribute set to pass to `buildPythonPackage`

     Type: buildPythonPackage :: AttrSet -> AttrSet

     Example:
       # buildPythonPackage { pyproject = lib.importTOML }
       { }  # Filtered dependency structure in the schema of `lib.pep621.parseDependencies`
  */
  buildPythonPackage =
    { dependencies
      # Python derivation
    , python
      # Unmarshaled pyproject.toml contents
    , pyproject
    }: {
      pname = pyproject.project.name;
    } // lib.optionalAttrs (pyproject.project ? version) // {
      inherit (pyproject.project) version;
    };

})
