{ lib, ... }:
let
  inherit (builtins) split filter match length elemAt head foldl' fromJSON typeOf compareVersions;
  inherit (lib) fix isString toInt sublist;
  inherit (import ./util.nix { inherit lib; }) splitComma;

  # A version of lib.toInt that supports leading zeroes
  toIntRelease = s:
    let
      n = fromJSON (head (match "0?([[:digit:]]+)" s));
    in
    if s == "*" then s else (assert typeOf n == "int"; n);

  emptyVersion = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ ]; };

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
  normalizedReleaseType = type: normalizedReleaseTypes.${type} or type;

  # Compare the release fields from the parsed version
  compareRelease = offset: ra: rb:
    let
      x = elemAt ra offset;
      y = elemAt rb offset;
    in
    if length ra == offset || length rb == offset then 0 else
    (
      if x == "*" || y == "*" then 0 # Wildcards are always considered equal
      else
        (
          if x > y then 1
          else if x < y then -1
          else compareRelease (offset + 1) ra rb
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

  # Strip leading dash from a string
  stripDash = s:
    let
      m = match "(-)(.+)" s;
    in
    if m != null then (elemAt m 1) else s;

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
fix (self: {

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
      # Split input into (_, epoch, release, modifiers)
      tokens = match "(([0-9]+)!)?([^-\+a-zA-Z]+)(.*)" version;
      tAt = elemAt tokens;

      epoch = tAt 1;
      release = filter (s: isString s && s != "") (split "\\." (tAt 2));

      # Modifiers including local segment
      modifiers' = tAt 3;
      modPrimeAt = elemAt (match "([^\\+]*)\\+?(.*)" modifiers');
      modifiersSegment = modPrimeAt 0;
      local = modPrimeAt 1;

      modifiers =
        map
          (mod:
            let
              m = match "([^0-9]+)([0-9]+)" mod;
              mAt = elemAt m;
              type = stripDash (mAt 0);
              value = mAt 1;
            in
            {
              type = normalizedReleaseType type;
              value = toIntRelease value;
            })
          (filter (s: isString s && s != "") (split "\\." modifiersSegment));

    in
    if version == "" then emptyVersion
    else {
      # Return epoch defaulting to 0
      epoch =
        if epoch != null then toInt epoch
        else 0;
      release = map toIntRelease release;
      pre = lib.findFirst (mod: mod.type == "rc" || mod.type == "b" || mod.type == "a") null modifiers;
      post = lib.findFirst (mod: mod.type == "post") null modifiers;
      dev = lib.findFirst (mod: mod.type == "dev") null modifiers;
      # Local releases needs to be treated specially.
      # The value isn't just a straight up number, but an arbitrary string.
      local = if local != "" then local else null;
    };

  /* Parse a version conditional.

     Type: parseVersionCond :: string -> AttrSet

     Example:
       # parseVersionCond ">=3.0.0rc1"
       {
         op = ">=";
         version = {
           dev = null;
           epoch = 0;
           local = null;
           post = null;
           pre = {
             type = "rc";
             value = 1;
           };
           release = [ 3 0 0 ];
         };
       }
  */
  parseVersionCond = cond: (
    let
      m = match " *([=><!~^]*) *(.+)" cond;
      mAt = elemAt m;
    in
    {
      op = mAt 0;
      version = self.parseVersion (mAt 1);
    }
  );

  /* Parse a list of version conditionals separated by commas.

     Type: parseVersionConds :: string -> [AttrSet]

     Example:
       # parseVersionConds ">=3.0.0rc1,<=4.0"
       [
         {
           op = ">=";
           version = {
             dev = null;
             epoch = 0;
             local = null;
             post = null;
             pre = {
               type = "rc";
               value = 1;
             };
             release = [ 3 0 0 ];
           };
         }
         {
           op = "<=";
           version = {
             dev = null;
             epoch = 0;
             local = null;
             post = null;
             pre = null;
             release = [ 4 0 ];
           };
         }
       ]
  */
  parseVersionConds = conds: map self.parseVersionCond (splitComma conds);

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
    (compareRelease 0 a.release b.release)

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
      # HACK: Local are arbitrary strings.
      # We do a best estimate by comparing local as versions using builtins.compareVersions.
      # This is strictly not correct but it's better than no handling..
      if a.local != null && b.local != null then compareVersions a.local b.local
      else if b.local != null then -1
      else 0
    )
  ];

  /* Map comparison operators as strings to a comparator function.

     Attributes:
       - [Compatible release clause](https://peps.python.org/pep-0440/#compatible-release): `~=`
       - [Version matching clause](https://peps.python.org/pep-0440/#version-matching): `==`
       - [Version exclusion clause](https://peps.python.org/pep-0440/#version-exclusion): `!=`
       - [Inclusive ordered comparison clause](https://peps.python.org/pep-0440/#inclusive-ordered-comparison): `<=`, `>=`
       - [Exclusive ordered comparison clause](https://peps.python.org/pep-0440/#exclusive-ordered-comparison): `<`, `>`
       - [Arbitrary equality clause](https://peps.python.org/pep-0440/#arbitrary-equality): `===`

     Type: operators.${operator} :: AttrSet -> AttrSet -> bool

     Example:
       # comparators."==" (parseVersion "3.0.0") (parseVersion "3.0.0")
       true
  */
  comparators = {
    "~=" = a: b: (
      # Local version identifiers are NOT permitted in this version specifier.
      assert a.local == null && b.local == null;
      self.comparators.">=" a b && self.comparators."==" a (b // {
        release = sublist 0 ((length b.release) - 1) b.release;
        # If a pre-release, post-release or developmental release is named in a compatible release clause as V.N.suffix, then the suffix is ignored when determining the required prefix match.
        pre = null;
        post = null;
        dev = null;
      })
    );
    "==" = a: b: self.compareVersions a b == 0;
    "!=" = a: b: self.compareVersions a b != 0;
    "<=" = a: b: self.compareVersions a b <= 0;
    ">=" = a: b: self.compareVersions a b >= 0;
    "<" = a: b: self.compareVersions a b < 0;
    ">" = a: b: self.compareVersions a b > 0;
    "===" = throw "Arbitrary equality clause not supported";
    "" = _a: _b: true;
  };

})
