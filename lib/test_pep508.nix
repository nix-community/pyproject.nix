{ lib, pep508 }:
let
  inherit (builtins) mapAttrs;
in

lib.fix (self: {
  # parseMarkers is implicitly covered by parseString but would fail coverage checks otherwise
  parseMarkers = {
    testDummyCoverage = {
      expected = true;
      expr = true;
    };
  };

  parseString = mapAttrs (_: case: case // { expr = pep508.parseString case.input; }) {
    testSimple = {
      input = "blinker";
      expected = {
        name = "blinker";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    testVersioned = {
      input = "rich>=12.3.0";
      expected = {
        name = "rich";
        conditions = [
          {
            op = ">=";
            version = "12.3.0";
          }
        ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    testExtras = {
      input = "mkdocstrings[python]";
      expected = {
        name = "mkdocstrings";
        conditions = [ ];
        optionals = [ "python" ];
        markers = null;
        url = null;
      };
    };

    testVersionedWithDoubleConditions = {
      input = "packaging>=20.9,!=22.0";
      expected = {
        name = "packaging";
        conditions = [
          {
            op = ">=";
            version = "20.9";
          }
          {
            op = "!=";
            version = "22.0";
          }
        ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    testVersionedWithExtras = {
      input = "cachecontrol[filecache]>=0.13.0";
      expected = {
        name = "cachecontrol";
        conditions = [
          {
            op = ">=";
            version = "0.13.0";
          }
        ];
        optionals = [ "filecache" ];
        markers = null;
        url = null;
      };
    };

    testVersionedWithMarker = {
      input = "tomli>=1.1.0; python_version < \"3.11\"";
      expected = {
        name = "tomli";
        conditions = [
          {
            op = ">=";
            version = "1.1.0";
          }
        ];
        optionals = [ ];
        markers = {
          op = "<";
          lhs = "python_version";
          rhs = "\"3.11\"";
        };
        url = null;
      };
    };

    testNameWithURL = {
      input = "name@http://foo.com";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = "http://foo.com";
      };
    };

    testDottedNames = {
      input = "A.B-C_D";
      expected = {
        name = "A.B-C_D";
        conditions = [ ];
        optionals = [ ];
        markers = null;
        url = null;
      };
    };

    testCompleteExample = {
      input = "name [fred,bar] @ http://foo.com ; python_version=='2.7'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ "fred" "bar" ];
        markers = {
          op = "==";
          lhs = "python_version";
          rhs = "'2.7'";
        };
        url = "http://foo.com";
      };
    };

    testDoubleMarkers = {
      input = "name; os_name=='a' or os_name=='b'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "or";
          lhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'a'";
          };
          rhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'b'";
          };
        };
        url = null;
      };
    };

    testDoubleMarkersWithOptionals = {
      input = "name[quux, strange];python_version<'2.7' and platform_version=='2'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ "quux" "strange" ];
        markers = {
          op = "and";
          lhs = {
            op = "<";
            lhs = "python_version";
            rhs = "'2.7'";
          };
          rhs = {
            op = "==";
            lhs = "platform_version";
            rhs = "'2'";
          };
        };
        url = null;
      };
    };

    testExprGroups = {
      # Should parse as (a and b) or c
      input = "name; os_name=='a' and os_name=='b' or os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "or";
          lhs = {
            op = "and";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'a'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
          };
          rhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'c'";
          };
        };
        url = null;
      };
    };

    testExprGroupsInt = {
      # Overriding precedence -> a and (b or c)
      input = "name; os_name=='a' and (os_name=='b' or os_name=='c')";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "and";
          lhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'a'";
          };
          rhs = {
            op = "or";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'c'";
            };
          };
        };
        url = null;
      };
    };

    testExprGroupsTail = {
      # should parse as a or (b and c)
      input = "name; os_name=='a' or os_name=='b' and os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "or";
          lhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'a'";
          };
          rhs = {
            op = "and";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'c'";
            };
          };
        };
        url = null;
      };
    };

    testExprGroupsHead = {
      # Overriding precedence -> (a or b) and c
      input = "name; (os_name=='a' or os_name=='b') and os_name=='c'";
      expected = {
        name = "name";
        conditions = [ ];
        optionals = [ ];
        markers = {
          op = "and";
          lhs = {
            op = "or";
            lhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'a'";
            };
            rhs = {
              op = "==";
              lhs = "os_name";
              rhs = "'b'";
            };
          };
          rhs = {
            op = "==";
            lhs = "os_name";
            rhs = "'c'";
          };
        };
        url = null;
      };
    };
  };

  mkEnviron = mapAttrs (_: case: case // { expr = pep508.mkEnviron case.input; }) (
    let
      # Mock python derivations so we don't have to keep a pkgs reference
      mkPython =
        { pname ? "python"
        , version
        , pythonVersion ? version
        , implementation ? "cpython"
        , isLinux ? false
        , isDarwin ? false
        }: {
          inherit pname version;
          passthru = {
            inherit pythonVersion implementation;
          };
          stdenv = {
            inherit isLinux isDarwin;
            targetPlatform.parsed.cpu.name = "x86_64";
          };
        };

    in
    {
      testPython38Linux = {
        input = mkPython {
          version = "3.8.2";
          pythonVersion = "3.8";
          isLinux = true;
        };
        expected = {
          implementation_name = "cpython";
          implementation_version = "3.8.2";
          os_name = "posix";
          platform_machine = "x86_64";
          platform_python_implementation = "CPython";
          platform_release = "";
          platform_system = "Linux";
          platform_version = "";
          python_full_version = "3.8.2";
          python_version = "3.8";
          sys_platform = "linux";
        };
      };

      testPython311Darwin = {
        input = mkPython {
          version = "3.11.4";
          pythonVersion = "3.11";
          isDarwin = true;
        };
        expected = {
          implementation_name = "cpython";
          implementation_version = "3.11.4";
          os_name = "posix";
          platform_machine = "x86_64";
          platform_python_implementation = "CPython";
          platform_release = "";
          platform_system = "Darwin";
          platform_version = "";
          python_full_version = "3.11.4";
          python_version = "3.11";
          sys_platform = "darwin";
        };
      };

      testPypy3Linux = {
        input = mkPython {
          pname = "pypy";
          version = "7.3.11";
          pythonVersion = "3.9";
          isLinux = true;
          implementation = "pypy";
        };
        expected = {
          implementation_name = "pypy";
          implementation_version = "7.3.11";
          os_name = "posix";
          platform_machine = "x86_64";
          platform_python_implementation = "PyPy";
          platform_release = "";
          platform_system = "Linux";
          platform_version = "";
          python_full_version = "7.3.11";
          python_version = "3.9";
          sys_platform = "linux";
        };
      };
    }
  );

  evalMarkers = mapAttrs (_: case: case // { expr = pep508.evalMarkers case.input.environ case.input.markers; }) {
    testTrivial = {
      input = {
        environ = self.mkEnviron.testPython38Linux.expected;
        inherit (self.parseString.testVersionedWithMarker.expected) markers;
      };
      expected = true;
    };

    testDoubleMarkers = {
      input = {
        environ = self.mkEnviron.testPython38Linux.expected;
        inherit (self.parseString.testDoubleMarkersWithOptionals.expected) markers;
      };
      expected = false;
    };

  };
})
