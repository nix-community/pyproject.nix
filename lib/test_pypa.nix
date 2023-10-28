{ lib, pypa, ... }:
let
  inherit (pypa) normalizePackageName parsePythonTag parseABITag parseWheelFileName isWheelFileName;
  inherit (lib) mapAttrs';

in

{
  normalizePackageName = mapAttrs'
    (n: _: {
      name = "testNormalize${n}";
      value = { expr = normalizePackageName n; expected = "friendly-bard"; };
    })
    {
      "friendly-bard" = { };
      "Friendly-Bard" = { };
      "FRIENDLY-BARD" = { };
      "friendly.bard" = { };
      "friendly_bard" = { };
      "friendly--bard" = { };
      "FrIeNdLy-._.-bArD" = { };
    };

  parsePythonTag = {
    testWithFlags = {
      expr = parsePythonTag "cp37";
      expected = {
        implementation = "cpython";
        version = "37";
      };
    };
  };

  parseABITag = {
    testWithFlags = {
      expr = parseABITag "cp37dmu";
      expected = {
        flags = [ "d" "m" "u" ];
        implementation = "cpython";
        version = "37";
      };
    };
  };
  parseWheelFileName = {
    testSimple = {
      expr = parseWheelFileName "distribution-1.0-1-py27-none-any.whl";
      expected = {
        abiTag = {
          implementation = "none";
          version = null;
          flags = [ ];
        };
        buildTag = "1";
        distribution = "distribution";
        languageTags = [
          {
            implementation = "python";
            version = "27";
          }
        ];
        platformTags = [ "any" ];
        version = "1.0";
      };
    };

    testComplex = {
      expr = parseWheelFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
      expected = {
        abiTag = {
          implementation = "abi";
          version = "3";
          flags = [ ];
        };
        buildTag = null;
        distribution = "cryptography";
        languageTags = [
          {
            implementation = "cpython";
            version = "37";
          }
        ];
        platformTags = [ "manylinux_2_17_aarch64" "manylinux2014_aarch64" ];
        version = "41.0.1";
      };
    };

    testMultipleLanguageTags = {
      expr = parseWheelFileName "Werkzeug-1.0.0-py2.py3-none-any.whl";
      expected = {
        abiTag = {
          implementation = "none";
          version = null;
          flags = [ ];
        };
        buildTag = null;
        distribution = "Werkzeug";
        languageTags = [
          {
            implementation = "python";
            version = "2";
          }
          {
            implementation = "python";
            version = "3";
          }
        ];
        platformTags = [ "any" ];
        version = "1.0.0";
      };
    };
  };

  isWheelFileName = {
    testSimple = {
      expr = isWheelFileName "distribution-1.0-1-py27-none-any.whl";
      expected = true;
    };

    testSimpleNoMatch = {
      expr = isWheelFileName "distribution-1.0-1-py27-none-any.tar.gz";
      expected = false;
    };

    testComplex = {
      expr = isWheelFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
      expected = true;
    };

    testComplexNoMatch = {
      expr = isWheelFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.zip";
      expected = false;
    };
  };
}
