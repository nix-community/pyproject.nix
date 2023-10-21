{ lib
, pep508
, ...
}:
let
  inherit (builtins) match head tail typeOf split filter foldl' readFile dirOf;

  stripStr = s:
    let
      t = match "[\t ]*(.*[^\t ])[\t ]*" s;
    in
    if t == null
    then ""
    else head t;

  uncomment = l: head (match " *([^#]*).*" l);

in
lib.fix (self: {

  /* Parse dependencies from requirements.txt

     Type: parseRequirementsTxt :: AttrSet -> list

     Example:
     # parseRequirements { requirements = builtins.readFile ./requirements.txt; root = ./.; }
     [ { flags = []; requirement = {}; # Returned by pep508.parseString } ]
  */

  parseRequirementsTxt =
    # The contents of or path to requirements.txt
    requirements:
    let
      isPath = typeOf requirements == "path";
      root = if isPath then dirOf requirements else null;

      # Requirements without comments and no empty strings
      requirements' = if isPath then readFile requirements else requirements;
      lines' = filter (l: l != "") (map uncomment (filter (l: typeOf l == "string") (split "\n" requirements')));
      # Fold line continuations
      inherit ((foldl'
        (
          acc: l':
          let
            m = match "(.+) *\\\\" l';
            continue = m != null;
            l = stripStr (
              if continue
              then (head m)
              else l'
            );
          in
          if continue
          then {
            line = acc.line ++ [ l ];
            inherit (acc) lines;
          }
          else {
            line = [ ];
            lines = acc.lines ++ [ (acc.line ++ [ l ]) ];
          }
        )
        {
          lines = [ ];
          line = [ ];
        }
        lines')) lines;

    in
    foldl'
      (acc: l:
      let
        m = match "-(c|r) (.+)" (head l);
      in
      acc ++ (
        # Common case, parse string
        if m == null
        then [{
          requirement = pep508.parseString (head l);
          flags = tail l;
        }]

        # Don't support constraint files
        else if (head m) == "c" then throw "Unsupported flag: -c"

        # Recursive requirements.txt
        else
          (self.parseRequirementsTxt (
            if root == null then throw "When importing recursive requirements.txt requirements needs to be passed as a path"
            else root + "/${head (tail m)}"
          ))
      ))
      [ ]
      lines;
})
