{
  lib,
  pep508,
  pep621,
  pep723,
  pypa,
  ...
}:

let
  inherit (pep723) parseScript;
  inherit (pypa) normalizePackageName;
  inherit (lib)
    isString
    isPath
    readFile
    fix
    concatMap
    removeSuffix
    ;
  inherit (builtins) baseNameOf;

in
fix (self: {

  /*
    Load a PEP-723 metadata script from file path or string.

    Example:
      # loadScript { script = ./with-inline-metadata.py; }
      {
        name = "with-inline-metadata";
        metadata = { ... }; # Contains dependencies and requires-python
        render = { python }: ...; # renderScript with loaded script pre-applied
      }
  */
  loadScript =
    {
      name ?
        if isPath script then (removeSuffix ".py" (baseNameOf script)) else throw "Missing argument name",
      script,
    }:
    let
      script' =
        if isString script then
          script
        else if isPath script then
          readFile script
        else
          throw "Script must be passed as path or string";

    in
    fix (scriptSelf: {
      name = normalizePackageName name;
      script = script';
      metadata = pep723.parseScript script';
      render =
        { python }:
        self.renderScript {
          script = scriptSelf;
          inherit python;
        };
    });

  /*
    Render a loaded PEP-723 script as a string.

    Example:
      let
        script = loadScript { script = ./with-inline-metadata.py; };
      in pkgs.writeScript script.name (loaded.render { python = pkgs.python3; })
  */
  renderScript =
    { script, python, environ ? pep508.mkEnviron python }:
    let
      filteredDeps = pep621.filterDependenciesByEnviron environ [ ] {
        inherit (script.metadata) dependencies;
        extras = { };
        build-systems = [ ];
      };

      pythonEnv = python.withPackages (
        pythonPackages:
        concatMap (
          dep:
          let
            pkg = pythonPackages.${dep.name};
          in
          [ pkg ] ++ concatMap (extra: pkg.optional-dependencies.${extra} or [ ]) dep.extras
        ) filteredDeps.dependencies
      );
    in
    "#!${pythonEnv.interpreter}\n" + script.script;

})
