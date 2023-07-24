{ lib, pep508, ... }:
let
  inherit (builtins) typeOf fromTOML readFile mapAttrs;
  inherit (lib) isString;

in
lib.fix (_self: {

  /* Parse fields defined by PEP-621 from pyproject.toml.

     Parses:
       - `project.dependencies`
       - `project.optional-dependencies`
       - `project.build-system`

     All other fields are returned verbatim.

     Type: parsePyproject :: (AttrSet | string | path) -> AttrSet

     Example:
       # parsePyproject ./pyproject.toml
       { project = { ... }; }  # Full structure omitted
  */
  parsePyproject = pyproject:
    let
      inputType = typeOf pyproject;
      pyproject' =
        if inputType == "path" then fromTOML (readFile pyproject)
        else if inputType == "string" then fromTOML pyproject
        else if inputType == "set" then pyproject
        else throw "Unsupported input type: ${inputType}";

      inherit (pyproject') project build-system;

    in
    assert isString project.name;
    (pyproject' // lib.optionalAttrs (pyproject' ? project) {
      # Defined by PEP-621
      project = project // {
        dependencies = map pep508.parseString (project.dependencies or [ ]);
        optional-dependencies = mapAttrs (_: map pep508.parseString) (project.optional-dependencies or { });
      };
    } // lib.optionalAttrs (pyproject' ? build-system) {
      # Defined by PEP-518
      build-system = build-system // {
        requires = map pep508.parseString build-system.requires;
      };
    });

})
