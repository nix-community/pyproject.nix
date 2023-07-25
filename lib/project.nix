{ lib, pep518, pep621, ... }:

lib.fix (_self: {

  /* Load dependencies from a pyproject.toml.

     Type: pyproject :: AttrSet -> AttrSet

     Example:
       # pyproject { pyproject = lib.importTOML }
       {
         dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
         build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
         pyproject = { }; # The unmarshaled contents of pyproject.toml
       }
  */
  loadPyproject =
    {
      # The unmarshaled contents of pyproject.toml
      pyproject
      # Example: extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
    , extrasAttrPaths ? [ ]
    }: {
      dependencies = pep621.parseDependencies { inherit pyproject extrasAttrPaths; };
      build-systems = pep518.parseBuildSystems pyproject;
      inherit pyproject;
    };

})
