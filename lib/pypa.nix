{ lib, ... }:
let
  inherit (builtins) concatStringsSep filter split match elemAt;
  inherit (lib) isString toLower;

  matchWheelFileName = match "([^-]+)-([^-]+)(-([[:digit:]][^-]*))?-([^-]+)-([^-]+)-(.+).whl";

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
lib.fix (self: {
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

  /* Check whether string is a wheel file or not.

     Type: isWheelFileName :: string -> bool

     Example:
     # isWheelFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
     true
  */
  isWheelFileName = name: matchWheelFileName name != null;

  /* Parse PEP-427 wheel file names.

     Type: parseFileName :: string -> AttrSet

     Example:
     # parseFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
     {
      abiTag = {
        implementation = "abi";
        version = "3";
        flags = [ ];
      };
      buildTag = null;
      distribution = "cryptography";
      languageTags = [  # Parsed by pypa.parsePythonTag
        {
          implementation = "cpython";
          version = "37";
        }
      ];
      platformTags = [ "manylinux_2_17_aarch64" "manylinux2014_aarch64" ];
      version = "41.0.1";
    }
  */
  parseWheelFileName =
    # The wheel filename is `{distribution}-{version}(-{build tag})?-{python tag}-{abi tag}-{platform tag}.whl`.
    name:
    let
      m = matchWheelFileName name;
      mAt = elemAt m;
    in
    assert m != null; {
      distribution = mAt 0;
      version = mAt 1;
      buildTag = mAt 3;
      languageTags = map self.parsePythonTag (filter isString (split "\\." (mAt 4)));
      abiTag = self.parseABITag (mAt 5);
      platformTags = filter isString (split "\\." (mAt 6));
    };
})
