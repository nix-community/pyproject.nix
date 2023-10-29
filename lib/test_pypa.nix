{ lib, pypa, mocks, ... }:
let
  inherit (pypa) normalizePackageName parsePythonTag parseABITag parseWheelFileName isWheelFileName isPythonTagCompatible isABITagCompatible isPlatformTagCompatible isWheelFileCompatible;
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

  isPythonTagCompatible = {
    testPython = {
      expr = isPythonTagCompatible mocks.cpythonLinux38 (parsePythonTag "py3");
      expected = true;
    };

    testCpython = {
      expr = isPythonTagCompatible mocks.cpythonLinux38 (parsePythonTag "cp3");
      expected = true;
    };

    testCpythonWithVersion = {
      expr = isPythonTagCompatible mocks.cpythonLinux38 (parsePythonTag "cp38");
      expected = true;
    };

    testCpythonWithVersionNoCompat = {
      expr = isPythonTagCompatible mocks.cpythonLinux38 (parsePythonTag "cp39");
      expected = false;
    };

    testPythonIncompatible = {
      expr = isPythonTagCompatible mocks.cpythonLinux38 (parsePythonTag "py2");
      expected = false;
    };
  };

  isABITagCompatible = {
    testCompatible = {
      expr = isABITagCompatible mocks.cpythonLinux38 (parseABITag "cp38");
      expected = true;
    };

    testIncompatible = {
      expr = isABITagCompatible mocks.cpythonLinux38 (parseABITag "cp39");
      expected = false;
    };
  };

  isPlatformTagCompatible = {
    testCompatible = {
      expr = isPlatformTagCompatible mocks.cpythonLinux38 "manylinux_2_5_x86_64";
      expected = true;
    };

    testCompatible2 = {
      expr = isPlatformTagCompatible mocks.cpythonLinux38 "manylinux1_x86_64";
      expected = true;
    };

    testIncompatibleArch = {
      expr = isPlatformTagCompatible mocks.cpythonLinux38 "manylinux_2_5_armv7l";
      expected = false;
    };

    testIncompatibleLibc = {
      expr = isPlatformTagCompatible mocks.cpythonLinux38 "musllinux_1_1_x86_64";
      expected = false;
    };
  };

  isWheelFileCompatible = {
    testIncompatible = {
      expr = isWheelFileCompatible mocks.cpythonLinux38 (parseWheelFileName "cryptography-41.0.1-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl");
      expected = false;
    };

    testCompatible = {
      expr = isWheelFileCompatible mocks.cpythonLinux38 (parseWheelFileName "cryptography-41.0.1-cp38-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl");
      expected = true;
    };
  };
}
