{ lib, pep440 }:
let
  inherit (pep440) parseVersion compareVersions;

in

lib.fix (_self: {

  parseVersion = {
    testSimple = {
      expr = parseVersion "3.0.0";
      expected = {
        dev = null;
        epoch = 0;
        local = null;
        post = null;
        pre = null;
        release = [ 3 0 0 ];
      };
    };

    testSimplePost = {
      expr = parseVersion "3.0.0post2";
      expected = {
        dev = null;
        epoch = 0;
        local = null;
        post = {
          type = "post";
          value = 2;
        };
        pre = null;
        release = [ 3 0 0 ];
      };
    };

    testSimpleRc = {
      expr = parseVersion "3.0.0rc1";
      expected = {
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
    };

    testSimpleRcNormalized = {
      expr = parseVersion "3.0.0pre1";
      expected = {
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
    };

    testImplicitPost = {
      expr = parseVersion "3.0.0-1";
      expected = {
        dev = null;
        epoch = 0;
        local = null;
        post = {
          type = "post";
          value = 1;
        };
        pre = null;
        release = [ 3 0 0 ];
      };
    };

    testDev = {
      expr = parseVersion "1.2.0dev21";
      expected = {
        dev = {
          type = "dev";
          value = 21;
        };
        epoch = 0;
        local = null;
        post = null;
        pre = null;
        release = [ 1 2 0 ];
      };
    };

    testLocal = {
      expr = parseVersion "1.2+4.3";
      expected = {
        dev = null;
        epoch = 0;
        local = {
          type = "+";
          value = 4;
        };
        post = null;
        pre = null;
        release = [ 1 2 3 ];
      };
    };

    testWildcard = {
      expr = parseVersion "3.2.*";
      expected = {
        dev = null;
        epoch = 0;
        local = null;
        post = null;
        pre = null;
        release = [ 3 2 "*" ];
      };
    };

    testComplex = {
      expr = parseVersion "1.0b2.post345.dev456";
      expected = {
        dev = {
          type = "dev";
          value = 456;
        };
        epoch = 0;
        local = null;
        post = {
          type = "post";
          value = 345;
        };
        pre = {
          type = "b";
          value = 2;
        };
        release = [ 1 0 ];
      };
    };

    testepoch = {
      expr = parseVersion "1!2.0";
      expected = {
        dev = null;
        epoch = 2;
        local = null;
        post = null;
        pre = null;
        release = [ 1 0 ];
      };
    };
  };

  compareVersions = {
    testSimple = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0");
      expected = 0;
    };

    testSimpleRc = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0rc1");
      expected = 1;
    };

    testSimpleRcInv = {
      expr = compareVersions (parseVersion "3.0.0rc1") (parseVersion "3.0.0");
      expected = -1;
    };

    testSimplePost = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0post1");
      expected = -1;
    };

    testSimplePostInv = {
      expr = compareVersions (parseVersion "3.0.0post1") (parseVersion "3.0.0");
      expected = 1;
    };

    testSimpleDev = {
      expr = compareVersions (parseVersion "3.0.0dev3") (parseVersion "3.0.0dev2");
      expected = 1;
    };

    testSimpleDevInv = {
      expr = compareVersions (parseVersion "3.0.0dev2") (parseVersion "3.0.0dev3");
      expected = -1;
    };

    testSameVersionDifferentRc = {
      expr = compareVersions (parseVersion "2.3.1rc2") (parseVersion "2.3.1rc1");
      expected = 1;
    };

    testComplex = {
      expr = compareVersions (parseVersion "1.0b2.post345.dev456") (parseVersion "1.0b2.post345");
      expected = -1;
    };

    testEpoch = {
      expr = compareVersions (parseVersion "1.0") (parseVersion "1!2.0");
      expected = -1;
    };

    testEpochInv = {
      expr = compareVersions (parseVersion "1!2.0") (parseVersion "1.0");
      expected = 1;
    };

    testWildcard = {
      expr = compareVersions (parseVersion "1.0.0") (parseVersion "1.0.*");
      expected = 0;
    };

    testWildcardNotEq = {
      expr = compareVersions (parseVersion "1.2.0") (parseVersion "1.0.*");
      expected = 1;
    };
  };


})
