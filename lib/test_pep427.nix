{ pep427, ... }:
let
  inherit (pep427) parseFileName isWheelFileName;
in
{
  parseFileName = {
    testSimple = {
      expr = parseFileName "distribution-1.0-1-py27-none-any.whl";
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
      expr = parseFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
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
      expr = parseFileName "Werkzeug-1.0.0-py2.py3-none-any.whl";
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
