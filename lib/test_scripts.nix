{
  scripts,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) length readFile isString;

in
{
  loadScript = {
    testLoadFile = {
      expr =
        let
          loaded = scripts.loadScript { script = ./fixtures/pep723.py; };
        in
        assert loaded ? name;
        assert loaded ? script;
        assert isString loaded.script;
        assert length loaded.metadata.dependencies == 2;
        loaded.name;
      expected = "pep723";
    };

    testLoadInline = {
      expr =
        let
          loaded = scripts.loadScript {
            script = readFile ./fixtures/pep723.py;
            name = "pep723";
          };
        in
        assert isString loaded.script;
        loaded.name;
      expected = "pep723";
    };
  };

  renderWithPackages = {
    testRender =
      let
        python = pkgs.python3;
        contents = readFile ./fixtures/pep723.py;
      in
      {
        expr =
          let
            rendered = (scripts.loadScript { script = contents; }).renderWithPackages { inherit python; };
          in
          rendered;
        # Reconstruct rendered script
        expected =
          "#!"
          + (python.withPackages (ps: [
            ps.requests
            ps.rich
          ])).interpreter
          + "\n"
          + contents;
      };
  };
}
