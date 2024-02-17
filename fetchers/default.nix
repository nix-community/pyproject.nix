{ lib
, python3
, runCommand
, stdenvNoCC
}:
let
  inherit (builtins) filter head nixPath;

  # Predict URL from the PyPI index.
  # Args:
  #   pname: package name
  #   file: filename including extension
  #   hash: SRI hash
  #   kind: Language implementation and version tag
in
lib.mapAttrs (_: func: lib.makeOverridable func) {

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
