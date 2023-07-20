{ lib }:
let
  inherit (builtins) split filter match length elemAt;
  inherit (lib) fix isString toInt toLower;

  filterNull = filter (x: x != null);

  # Return a list elem at index with a default value if it doesn't exist
  optionalElem = list: idx: default: if length list >= idx + 1 then elemAt list idx else default;

  # We consider some words to be alternate spellings of other words and
  # in those cases we want to normalize the spellings to our preferred
  # spelling.
  normalizedReleaseTypes = {
    alpha = "a";
    beta = "b";
    c = "rc";
    pre = "rc";
    preview = "rc";
    rev = "post";
    r = "post";
    "-" = "post";
  };

  # Parse a release (pre/post/whatever) attrset from split tokens
  parseReleaseSuffix = patterns: tokens:
    let
      matches = map
        (x:
          let
            type = toLower (elemAt x 0);
            value = elemAt x 1;
          in
          {
            type = normalizedReleaseTypes.${type} or type;
            value = if value != "" then toInt value else 0;
          })
        (filterNull (map (match "[0-9]*(${patterns})([0-9]*)") tokens));
    in
    assert length matches <= 1; optionalElem matches 0 null;

  parsePre = parseReleaseSuffix "a|b|c|rc|alpha|beta|pre|preview";
  parsePost = parseReleaseSuffix "post|rev|r|\-";
  parseDev = parseReleaseSuffix "dev";
  parseLocal = parseReleaseSuffix "\\+";

in
fix (_self: {

  /* Parse a version according to PEP-440.

     Type: parseVersion :: string -> AttrSet

     Example:
       # parseVersion "3.0.0rc1"
       {
         dev = null;
         epoch = 0;
         local = null;
         post = null;
         pre = {
           type = "rc";
           value = 1;
         };
         release = [ 3 0 0 ];
       }
  */
  parseVersion = version:
    let
      tokens = filter isString (split "\\." version);
    in
    {
      # Return epoch defaulting to 0
      epoch = toInt (optionalElem (filterNull (map (match "[0-9]+!([0-9]+)") tokens)) 0 "0");
      release = map (t: (x: if x == "*" then x else toInt x) (elemAt t 0)) (filterNull (map (match "([\\*0-9])*.*") tokens));
      pre = parsePre tokens;
      post = parsePost tokens;
      dev = parseDev tokens;
      local = parseLocal tokens;
    };

})
