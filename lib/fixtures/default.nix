let
  inherit (builtins) mapAttrs readFile fromTOML readDir;
in
mapAttrs (name: _: fromTOML (readFile ./${name})) (readDir ./.)
