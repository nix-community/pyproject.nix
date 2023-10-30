{ lib, pep600, pep656, ... }:
let
  inherit (builtins) concatStringsSep filter split match elemAt;
  inherit (lib) isString toLower;
  inherit (lib.strings) hasPrefix;

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
     # parsePythonTag "cp37"
     {
       implementation = "cpython";
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
      abiTag = {  # Parsed by pypa.parseABITag
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

  /* Check whether an ABI tag is compatible with this python interpreter.

     Type: isABITagCompatible :: derivation -> string -> bool

     Example:
     # isABITagCompatible pkgs.python3 (pypa.parseABITag "cp37")
     true
  */
  isABITagCompatible =
    # Python interpreter derivation
    python:
    # ABI tag string
    abiTag:
    let
      inherit (python.passthru.sourceVersion) major minor;
      inherit (python.passthru) implementation;
    in
    (
      # None is a wildcard compatible with any implementation
      (abiTag.implementation == "none" || abiTag.implementation == "any")
      ||
      # implementation == sys.implementation.name
      abiTag.implementation == implementation
      ||
      # The CPython stable ABI is abi3 as in the shared library suffix.
      (abiTag.implementation == "abi" && implementation == "cpython")
    )
    &&
    # Check version
    (
      abiTag.version == null || hasPrefix abiTag.version (major + minor)
    );

  /* Check whether a platform tag is compatible with this python interpreter.

     Type: isPlatformTagCompatible :: derivation -> string -> bool

     Example:
     # isPlatformTagCompatible pkgs.python3 "manylinux2014_x86_64"
     true
  */
  isPlatformTagCompatible =
    # Python interpreter derivation
    python:
    # Python tag
    platformTag:
    let
      platform = python.stdenv.targetPlatfform;
    in
    if platformTag == "any" then true
    else if hasPrefix "manylinux" platformTag then pep600.manyLinuxTagCompatible python.stdenv platformTag
    else if hasPrefix "musllinux" platformTag then pep656.muslLinuxTagCompatible python.stdenv platformTag
    else if hasPrefix "macosx" platformTag then (throw "Macosx tags not yet supported")
    else if platformTag == "win32" then (platform.isWindows && platform.is32Bit && platform.isx86)
    else if platformTag == "win_amd64" then (platform.isWindows && platform.is64Bit && platform.isx86_64)
    else throw "Unknown platform tag: '${platformTag}'";

  /* Check whether a Python language tag is compatible with this Python interpreter.

     Type: isPythonTagCompatible :: derivation -> AttrSet -> bool

     Example:
     # isPlatformTagCompatible pkgs.python3 (pypa.parsePythonTag "py3")
     true
  */
  isPythonTagCompatible =
    # Python interpreter derivation
    python:
    # Python tag
    pythonTag:
    let
      inherit (python.passthru.sourceVersion) major minor;
      inherit (python.passthru) implementation;
    in
    (
      # Python is a wildcard compatible with any implementation
      pythonTag.implementation == "python"
      ||
      # implementation == sys.implementation.name
      pythonTag.implementation == implementation
    )
    &&
    # Check version
    (
      pythonTag.version == null || hasPrefix pythonTag.version (major + minor)
    );

  /* Check whether wheel file name is compatible with this python interpreter.

     Type: isWheelFileCompatible :: derivation -> AttrSet -> bool

     Example:
     # isWheelFileCompatible pkgs.python3 (pypa.parseWheelFileName "Pillow-9.0.1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl")
     true
  */
  isWheelFileCompatible =
    # Python interpreter derivation
    python:
    # The parsed wheel filename
    file:
    (
      self.isABITagCompatible python file.abiTag
      &&
      lib.any (self.isPythonTagCompatible python) file.languageTags
      &&
      lib.any (self.isPlatformTagCompatible python) file.platformTags
    );
})
