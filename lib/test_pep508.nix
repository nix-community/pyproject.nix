{ lib
, pep508
, mocks
, ...
}:

let
  inherit (builtins) mapAttrs;
  inherit (lib) fix;

in
fix (self: {
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
        extras = [ ];
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
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 12 3 0 ];
            };
          }
        ];
        extras = [ ];
        markers = null;
        url = null;
      };
    };

    testExtras = {
      input = "mkdocstrings[python]";
      expected = {
        name = "mkdocstrings";
        conditions = [ ];
        extras = [ "python" ];
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
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 20 9 ];
            };
          }
          {
            op = "!=";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 22 0 ];
            };
          }
        ];
        extras = [ ];
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
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 0 13 0 ];
            };
          }
        ];
        extras = [ "filecache" ];
        markers = null;
        url = null;
      };
    };

    testVersionedWithMarker = {
      input = "tomli>=1.1.0; python_version < \"3.11\"";
      expected = {
        conditions = [
          {
            op = ">=";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 1 1 0 ];
            };
          }
        ];
        markers = {
          lhs = {
            type = "variable";
            value = "python_version";
          };
          op = "<";
          rhs = {
            type = "version";
            value = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 3 11 ];
            };
          };
          type = "compare";
        };
        name = "tomli";
        extras = [ ];
        url = null;
      };
    };

    testNameWithURL = {
      input = "name@http://foo.com";
      expected = {
        name = "name";
        conditions = [ ];
        extras = [ ];
        markers = null;
        url = "http://foo.com";
      };
    };

    testDottedNames = {
      input = "A.B-C_D";
      expected = {
        name = "A.B-C_D";
        conditions = [ ];
        extras = [ ];
        markers = null;
        url = null;
      };
    };

    testCompleteExample = {
      input = "name [fred,bar] @ http://foo.com ; python_version=='2.7'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            type = "variable";
            value = "python_version";
          };
          op = "==";
          rhs = {
            type = "version";
            value = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 2 7 ];
            };
          };
          type = "compare";
        };
        name = "name";
        extras = [ "fred" "bar" ];
        url = "http://foo.com";
      };
    };

    testDoubleMarkers = {
      input = "name; os_name=='a' or os_name=='b'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "a";
            };
            type = "compare";
          };
          op = "or";
          rhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "b";
            };
            type = "compare";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ ];
        url = null;
      };
    };

    testDoubleMarkersWithExtras = {
      input = "name[quux, strange];python_version<'2.7' and platform_version=='2'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              type = "variable";
              value = "python_version";
            };
            op = "<";
            rhs = {
              type = "version";
              value = {
                dev = null;
                epoch = 0;
                local = null;
                post = null;
                pre = null;
                release = [ 2 7 ];
              };
            };
            type = "compare";
          };
          op = "and";
          rhs = {
            lhs = {
              type = "variable";
              value = "platform_version";
            };
            op = "==";
            rhs = {
              type = "version";
              value = {
                dev = null;
                epoch = 0;
                local = null;
                post = null;
                pre = null;
                release = [ 2 ];
              };
            };
            type = "compare";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ "quux" "strange" ];
        url = null;
      };
    };

    testExprGroups = {
      # Should parse as (a and b) or c
      input = "name; os_name=='a' and os_name=='b' or os_name=='c'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "a";
              };
              type = "compare";
            };
            op = "and";
            rhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "b";
              };
              type = "compare";
            };
            type = "boolOp";
          };
          op = "or";
          rhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "c";
            };
            type = "compare";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ ];
        url = null;
      };
    };

    testExprGroupsInt = {
      # Overriding precedence -> a and (b or c)
      input = "name; os_name=='a' and (os_name=='b' or os_name=='c')";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "a";
            };
            type = "compare";
          };
          op = "and";
          rhs = {
            lhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "b";
              };
              type = "compare";
            };
            op = "or";
            rhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "c";
              };
              type = "compare";
            };
            type = "boolOp";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ ];
        url = null;
      };
    };

    testExprGroupsTail = {
      # should parse as a or (b and c)
      input = "name; os_name=='a' or os_name=='b' and os_name=='c'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "a";
            };
            type = "compare";
          };
          op = "or";
          rhs = {
            lhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "b";
              };
              type = "compare";
            };
            op = "and";
            rhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "c";
              };
              type = "compare";
            };
            type = "boolOp";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ ];
        url = null;
      };
    };

    testExprGroupsHead = {
      # Overriding precedence -> (a or b) and c
      input = "name; (os_name=='a' or os_name=='b') and os_name=='c'";
      expected = {
        conditions = [ ];
        markers = {
          lhs = {
            lhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "a";
              };
              type = "compare";
            };
            op = "or";
            rhs = {
              lhs = {
                type = "variable";
                value = "os_name";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "b";
              };
              type = "compare";
            };
            type = "boolOp";
          };
          op = "and";
          rhs = {
            lhs = {
              type = "variable";
              value = "os_name";
            };
            op = "==";
            rhs = {
              type = "string";
              value = "c";
            };
            type = "compare";
          };
          type = "boolOp";
        };
        name = "name";
        extras = [ ];
        url = null;
      };
    };
  };

  mkEnviron = mapAttrs (_: case: case // { expr = pep508.mkEnviron case.input; }) {
    testPython38Linux = {
      input = mocks.cpythonLinux38;
      expected = {
        implementation_name = {
          type = "string";
          value = "cpython";
        };
        implementation_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 8 2 ];
          };
        };
        os_name = {
          type = "string";
          value = "posix";
        };
        platform_machine = {
          type = "string";
          value = "x86_64";
        };
        platform_python_implementation = {
          type = "string";
          value = "CPython";
        };
        platform_release = {
          type = "string";
          value = "";
        };
        platform_system = {
          type = "string";
          value = "Linux";
        };
        platform_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ ];
          };
        };
        python_full_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 8 2 ];
          };
        };
        python_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 8 ];
          };
        };
        sys_platform = {
          type = "string";
          value = "linux";
        };
      };
    };

    testPython311Darwin = {
      input = mocks.cpythonDarwin311;
      expected = {
        implementation_name = {
          type = "string";
          value = "cpython";
        };
        implementation_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 11 4 ];
          };
        };
        os_name = {
          type = "string";
          value = "posix";
        };
        platform_machine = {
          type = "string";
          value = "x86_64";
        };
        platform_python_implementation = {
          type = "string";
          value = "CPython";
        };
        platform_release = {
          type = "string";
          value = "";
        };
        platform_system = {
          type = "string";
          value = "Darwin";
        };
        platform_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ ];
          };
        };
        python_full_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 11 4 ];
          };
        };
        python_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 11 ];
          };
        };
        sys_platform = {
          type = "string";
          value = "darwin";
        };
      };
    };

    testPypy3Linux = {
      input = mocks.pypy39Linux;
      expected = {
        implementation_name = {
          type = "string";
          value = "pypy";
        };
        implementation_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 7 3 11 ];
          };
        };
        os_name = {
          type = "string";
          value = "posix";
        };
        platform_machine = {
          type = "string";
          value = "x86_64";
        };
        platform_python_implementation = {
          type = "string";
          value = "PyPy";
        };
        platform_release = {
          type = "string";
          value = "";
        };
        platform_system = {
          type = "string";
          value = "Linux";
        };
        platform_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ ];
          };
        };
        python_full_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 7 3 11 ];
          };
        };
        python_version = {
          type = "version";
          value = {
            dev = null;
            epoch = 0;
            local = null;
            post = null;
            pre = null;
            release = [ 3 9 ];
          };
        };
        sys_platform = {
          type = "string";
          value = "linux";
        };
      };
    };
  };

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
        inherit (self.parseString.testDoubleMarkersWithExtras.expected) markers;
      };
      expected = false;
    };
  };
})
