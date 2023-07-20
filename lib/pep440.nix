{ lib, ... }:
let
  inherit (builtins) split filter match length elemAt head tail foldl';
  inherit (lib) fix isString toInt toLower;

  filterNull = filter (x: x != null);
  filterEmpty = filter (x: length x > 0);
  filterEmptyStr = filter (s: s != "");

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

  # Compare the release fields from the parsed version
  compareRelease = ra: rb:
    let
      x = head ra;
      y = head rb;
    in
    if length ra == 0 || length rb == 0 then 0 else
    (
      if x == "*" || y == "*" then 0 # Wildcards are always considered equal
      else
        (
          if x > y then 1
          else if x < y then -1
          else compareRelease (tail ra) (tail rb)
        )
    );

  # Normalized modifier to it's priority (in case we are comparing an alpha to a beta or similar)
  modifierPriority = {
    dev = -1;
    a = 0;
    b = 1;
    rc = 2;
    post = 3;
  };

  # Compare dev/pre/post/local release modifiers
  compareVersionModifier = x: y: assert x != null && y != null; let
    prioX = modifierPriority.${x.type};
    prioY = modifierPriority.${y.type};
  in
  if prioX == prioY then
    (
      if x.value == y.value then 0
      else if x.value > y.value then 1
      else -1
    )
  else if prioX > prioY then 1
  else 0;

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
      epoch = toInt (optionalElem (map head (filterNull (map (match "[0-9]+!([0-9]+)") tokens))) 0 "0");
      release = map (t: (x: if x == "*" then x else toInt x) (head t)) (filterEmpty (map (t: filterEmptyStr (match "([\\*0-9]*).*" t)) tokens));
      pre = parsePre tokens;
      post = parsePost tokens;
      dev = parseDev tokens;
      local = parseLocal tokens;
    };

  /* Compare two versions as parsed by `parseVersion` according to PEP-440.

     Returns:
       - -1 for less than
       - 0 for equality
       - 1 for greater than

     Type: compareVersions :: AttrSet -> AttrSet -> int

     Example:
       # compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0")
       0
  */
  compareVersions = a: b: foldl' (acc: comp: if acc != 0 then acc else comp) 0 [
    # mixing dev/pre/post like:
    # 1.0b2.post345.dev456
    # 1.0b2.post345
    # is valid and we need to consider them all.

    # Compare release field
    (compareRelease a.release b.release)

    # Compare pre release
    (
      if a.pre != null && b.pre != null then compareVersionModifier a.pre b.pre
      else if a.pre != null then -1
      else if b.pre != null then 1
      else 0
    )

    # Compare dev release
    (
      if a.dev != null && b.dev != null then compareVersionModifier a.dev b.dev
      else if a.dev != null then -1
      else if b.dev != null then 1
      else 0
    )

    # Compare post release
    (
      if a.post != null && b.post != null then compareVersionModifier a.post b.post
      else if a.post != null then 1
      else if b.post != null then -1
      else 0
    )

    # Compare epoch
    (
      if a.epoch == b.epoch then 0
      else if a.epoch > b.epoch then 1
      else -1
    )

    # Compare local
    (
      if a.local != null && b.local != null then compareVersionModifier a.local b.local
      else if b.local != null then -1
      else 0
    )
  ];
})
