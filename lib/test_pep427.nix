{ pep427, ... }:
let
  inherit (pep427) parseFileName isWheelFileName;
in
{
  parseFileName = {
    testSimple = {
      expr = parseFileName "distribution-1.0-1-py27-none-any.whl";
      expected = {
        abiTag = "none";
        buildTag = "1";
        distribution = "distribution";
        languageTag = "py27";
        platformTags = [ "any" ];
        version = "1.0";
      };
    };

    testComplex = {
      expr = parseFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl";
      expected = {
        abiTag = "abi3";
        buildTag = null;
        distribution = "cryptography";
        languageTag = "cp37";
        platformTags = [ "manylinux_2_17_aarch64" "manylinux2014_aarch64" ];
        version = "41.0.1";
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
