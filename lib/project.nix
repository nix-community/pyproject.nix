{ pep621, poetry, pip, lib, renderers, validators, ... }:

let
  inherit (builtins) mapAttrs;

  # Map over renderers and inject project argument.
  # This allows for a user interface like:
  # project.renderers.buildPythonPackage { } where project is already curried.
  curryProject = attrs: project: lib.mapAttrs (_: func: args: func (args // { inherit project; })) attrs;

in
lib.fix (self: {
  /* Load dependencies from a PEP-621 pyproject.toml.

     Type: loadPyproject :: AttrSet -> AttrSet

     Example:
       # loadPyproject { pyproject = lib.importTOML }
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
    }: lib.fix (project: {
      dependencies = pep621.parseDependencies { inherit pyproject extrasAttrPaths; };
      inherit pyproject;
      renderers = curryProject renderers project;
      validators = curryProject validators project;
    });

  /* Load dependencies from a PDM pyproject.toml.

     Type: loadPDMPyproject :: AttrSet -> AttrSet

     Example:
       # loadPyproject { pyproject = lib.importTOML }
       {
         dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
         build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
         pyproject = { }; # The unmarshaled contents of pyproject.toml
       }
  */
  loadPDMPyproject =
    {
      # The unmarshaled contents of pyproject.toml
      pyproject
    }: self.loadPyproject {
      inherit pyproject;
      extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
    };

  /* Load dependencies from a Poetry pyproject.toml.

     Type: loadPoetryPyproject :: AttrSet -> AttrSet

     Example:
       # loadPoetryPyproject { pyproject = lib.importTOML }
       {
         dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
         build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
         pyproject = { }; # The unmarshaled contents of pyproject.toml
       }
  */
  loadPoetryPyproject =
    {
      # The unmarshaled contents of pyproject.toml
      pyproject
    }:
    let
      pyproject-pep621 = poetry.translatePoetryProject pyproject;
    in
    lib.fix (project: {
      dependencies = poetry.parseDependencies pyproject;
      pyproject = pyproject-pep621;
      pyproject-poetry = pyproject;
      renderers = curryProject renderers project;
      validators = curryProject validators project;
    });

  /* Load dependencies from a requirements.txt.

     Note that as requirements.txt is lacking important project metadata this is incompatible with some renderers.

     Type: loadRequirementsTxt :: AttrSet -> AttrSet

     Example:
       # loadRequirementstxt { requirements = builtins.readFile ./requirements.txt; root = ./.; }
       {
         dependencies = { }; # Parsed dependency structure in the schema of `lib.pep621.parseDependencies`
         build-systems = [ ];  # Returned by `lib.pep518.parseBuildSystems`
         pyproject = null; # The unmarshaled contents of pyproject.toml
       }
  */
  loadRequirementsTxt =
    {
      # The contents of requirements.txt
      requirements
    }: lib.fix (project: {
      dependencies = {
        dependencies = map (x: x.requirement) (pip.parseRequirementsTxt requirements);
        extras = { };
        build-systems = [ ];
      };
      pyproject = null;
      renderers = curryProject renderers project;
      validators = curryProject validators project;
    });
})
