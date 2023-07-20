{ lib, pep440 }:
let
  inherit (pep440) parseVersion;

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
  };

})
