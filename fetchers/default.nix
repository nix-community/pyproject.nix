{ curl
, jq
, lib
, python3
, runCommand
, stdenvNoCC
}:
let
  inherit (builtins) substring filter head nixPath elemAt;
  inherit (lib) toLower;

  pyproject = import ../lib { inherit lib; };

  # Predict URL from the PyPI index.
  # Args:
  #   pname: package name
  #   file: filename including extension
  #   hash: SRI hash
  #   kind: Language implementation and version tag
  predictURLFromPypi =
    {
      # package name
      pname
    , # filename including extension
      file
    }:
    let
      matchedWheel = pyproject.pypa.matchWheelFileName file;
      wheelPythonVersion = builtins.elemAt matchedWheel 2;
      matchedEgg = pyproject.eggs.matchEggFileName file;
      kind =
        if matchedWheel != null then wheelPythonVersion
        else if matchedEgg != null then elemAt matchedEgg 2
        else "source";
    in
    "https://files.pythonhosted.org/packages/${kind}/${toLower (substring 0 1 file)}/${pname}/${file}";
in
lib.mapAttrs (_: func: lib.makeOverridable func) {
  /*
    Fetch from the PyPI index.

    At first we try to fetch the predicated URL but if that fails we
    will use the Pypi API to determine the correct URL.

    Type: fetchFromPypi :: AttrSet -> derivation
    */
  fetchFromPypi =
    {
      # package name
      pname
    , # filename including extension
      file
    , # the version string of the dependency
      version
    , # SRI hash
      hash
    , # Options to pass to `curl`
      curlOpts ? ""
    ,
    }:
    let
      predictedURL = predictURLFromPypi { inherit pname file; };
      wheelMatch = pyproject.pypa.matchWheelFileName file;
    in
    stdenvNoCC.mkDerivation {
      name = file;
      nativeBuildInputs = [
        curl
        jq
      ];
      isWheel = lib.strings.hasSuffix "whl" file;
      system = "builtin";

      preferLocalBuild = true;
      impureEnvVars =
        lib.fetchers.proxyImpureEnvVars
        ++ [
          "NIX_CURL_FLAGS"
        ];

      inherit pname file curlOpts predictedURL;

      # In case of a wheel, the non-normalized version from the filename is
      #   required in order to do a successful lookup via the pypi api.
      version =
        if wheelMatch != null
        then builtins.elemAt wheelMatch 1
        else version;

      builder = ./fetch-from-pypi.sh;

      outputHashMode = "flat";
      outputHashAlgo = null;
      outputHash = hash;

      passthru = {
        urls = [ predictedURL ]; # retain compatibility with nixpkgs' fetchurl
      };
    };

  /*
    Fetch from the PyPI legacy API.

    Some repositories (such as Devpi) expose the Pypi legacy API (https://warehouse.pypa.io/api-reference/legacy.html).

    Type: fetchFromLegacy :: AttrSet -> derivation
    */
  fetchFromLegacy =
    {
      # package name
      pname
    , # URL to package index
      url ? null
    , # URLs (multiple) to package index
      urls ? [ ]
    , # filename including extension
      file
    , # SRI hash
      hash
    ,
    }:
    let
      urls' = urls ++ lib.optional (url != null) url;

      pathParts = filter ({ prefix, path }: "NETRC" == prefix) nixPath; # deadnix: skip
      netrc_file =
        if (pathParts != [ ])
        then (head pathParts).path
        else "";
    in
    # Assert that we have at least one URL
    assert urls' != [ ]; runCommand file
      {
        nativeBuildInputs = [ python3 ];
        impureEnvVars = lib.fetchers.proxyImpureEnvVars;
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = hash;
        NETRC = netrc_file;
        passthru = {
          isWheel = lib.strings.hasSuffix "whl" file; # Poetry2nix compat
          urls = urls';
        };
      }
      ''
        python ${./fetch-from-legacy.py} ${lib.concatStringsSep " " (map (url: "--url ${lib.escapeShellArg url}") urls')} --pname ${pname} --filename ${file}
        mv ${file} $out
      '';
}
