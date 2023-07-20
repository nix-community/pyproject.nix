{ lib, pep440 }:
let
  inherit (pep440) parseVersion compareVersions;

in

lib.fix (_self: {

  parseVersion = {
    simple = {
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

    simplePost = {
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

    simpleRc = {
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

    simpleRcNormalized = {
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

    implicitPost = {
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

    dev = {
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

    local = {
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

    wildcard = {
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

    complex = {
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

    epoch = {
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
    simple = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0");
      expected = 0;
    };

    simpleRc = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0rc1");
      expected = 1;
    };

    simpleRcInv = {
      expr = compareVersions (parseVersion "3.0.0rc1") (parseVersion "3.0.0");
      expected = -1;
    };

    simplePost = {
      expr = compareVersions (parseVersion "3.0.0") (parseVersion "3.0.0post1");
      expected = -1;
    };

    simplePostInv = {
      expr = compareVersions (parseVersion "3.0.0post1") (parseVersion "3.0.0");
      expected = 1;
    };

    simpleDev = {
      expr = compareVersions (parseVersion "3.0.0dev3") (parseVersion "3.0.0dev2");
      expected = 1;
    };

    simpleDevInv = {
      expr = compareVersions (parseVersion "3.0.0dev2") (parseVersion "3.0.0dev3");
      expected = -1;
    };

    sameVersionDifferentRc = {
      expr = compareVersions (parseVersion "2.3.1rc2") (parseVersion "2.3.1rc1");
      expected = 1;
    };

    complex = {
      expr = compareVersions (parseVersion "1.0b2.post345.dev456") (parseVersion "1.0b2.post345");
      expected = -1;
    };

    epoch = {
      expr = compareVersions (parseVersion "1.0") (parseVersion "1!2.0");
      expected = -1;
    };

    epochInv = {
      expr = compareVersions (parseVersion "1!2.0") (parseVersion "1.0");
      expected = 1;
    };
  };


})
