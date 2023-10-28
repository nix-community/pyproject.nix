{ lib, ... }:
let
  inherit (builtins) concatStringsSep filter split match elemAt;
  inherit (lib) isString toLower;

  # Tag normalization documented in
  # https://packaging.python.org/en/latest/specifications/platform-compatibility-tags/#details
  normalizedImpls = {
    py = "python";
    cp = "cpython";
    ip = "ironpython";
    pp = "pypy";
    jy = "jython";
  };
  normalizeImpl = t: normalizedImpls.${t} or t;

  optionalString = s: if s != "" then s else null;

in
{
  /* Normalize package name as documented in https://packaging.python.org/en/latest/specifications/name-normalization/#normalization

     Type: normalizePackageName :: string -> string

     Example:
       # readPyproject "Friendly-Bard"
       "friendly-bard"
  */
  normalizePackageName =
    let
      concatDash = concatStringsSep "-";
      splitSep = split "[-_\.]+";
    in
    name: toLower (concatDash (filter isString (splitSep name)));

  /* Parse Python tags.

     As described in https://packaging.python.org/en/latest/specifications/platform-compatibility-tags/#python-tag.

     Type: parsePythonTag :: string -> AttrSet

     Example:
     # parseABITag "cp37dmu"
     {
       implementation = "cp";
       version = "37";
     }
     */
  parsePythonTag =
    tag:
    let
      m = match "([a-z]+)([0-9]*)" tag;
      mAt = elemAt m;
    in
    assert m != null; {
      implementation = normalizeImpl (mAt 0);
      version = mAt 1;
    };

  /* Parse ABI tags.

     As described in https://packaging.python.org/en/latest/specifications/platform-compatibility-tags/#python-tag.

     Type: parseABITag :: string -> AttrSet

     Example:
     # parseABITag "cp37dmu"
     {
       flags = [ "d" "m" "u" ];
       implementation = "cp";
       version = "37";
     }
  */
  parseABITag =
    tag:
    let
      m = match "([a-z]+)([0-9]*)([a-z]*)" tag;
      mAt = elemAt m;
    in
    assert m != null; {
      implementation = normalizeImpl (mAt 0);
      version = optionalString (mAt 1);
      flags = lib.stringToCharacters (mAt 2);
    };
}
