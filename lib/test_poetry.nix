{ fixtures
, poetry
, ...
}:
let
  inherit (poetry) translatePoetryProject parseDependencies;
in
{
  translatePoetryProject = {
    testProjectConversion = {
      expr = (translatePoetryProject fixtures."poetry.toml").project;
      expected = {
        authors = [
          {
            email = "sebastien@eustace.io";
            name = "Sébastien Eustace";
          }
        ];
        classifiers = [ "Topic :: Software Development :: Build Tools" "Topic :: Software Development :: Libraries :: Python Modules" ];
        description = "Python dependency management and packaging made easy.";
        keywords = [ "packaging" "dependency" "poetry" ];
        license = { text = "MIT"; };
        maintainers = [
          {
            email = "arun.neelicattu@gmail.com";
            name = "Arun Babu Neelicattu";
          }
          {
            email = "bjorn@neersighted.com";
            name = "Bjorn Neergaard";
          }
          {
            email = "branchevincent@gmail.com";
            name = "Branch Vincent";
          }
          {
            email = "github@accounts.brycedrennan.com";
            name = "Bryce Drennan";
          }
          {
            email = "danieleades@hotmail.com";
            name = "Daniel Eades";
          }
          {
            email = "radoering.poetry@gmail.com";
            name = "Randy Döring";
          }
          {
            email = "hello@stephsamson.com";
            name = "Steph Samson";
          }
          {
            email = "finswimmer77@gmail.com";
            name = "finswimmer";
          }
        ];
        name = "poetry";
        readme = "README.md";
        urls = {
          Documentation = "https://python-poetry.org/docs";
          Homepage = "https://python-poetry.org/";
          Repository = "https://github.com/python-poetry/poetry";
        };
        version = "1.4.2";
      };
    };
  };

  parseDependencies = {
    testParseDeps = {
      expr = parseDependencies fixtures."poetry.toml";
      expected = {
        build-systems = [
          {
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
            extras = [ ];
            markers = null;
            name = "poetry-core";
            url = null;
          }
        ];
        dependencies = [
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 0 2 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
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
                    release = [ 3 8 ];
                  };
                };
                type = "compare";
              };
              op = "and";
              rhs = {
                type = "bool";
                value = true;
              };
              type = "boolOp";
            };
            name = "backports.cached-property";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 10 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 11 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "build";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 12 9 ];
                };
              }
              {
                cond = "<";
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
            name = "cachecontrol";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "cleo";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 4 1 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 5 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "crashtest";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 21 2 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 22 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "dulwich";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 8 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 4 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "filelock";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 0 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "html5lib";
            url = null;
          }
          {
            conditions = [
              {
                op = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 4 4 ];
                };
              }
            ];
            extras = [ ];
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
                    release = [ 3 10 ];
                  };
                };
                type = "compare";
              };
              op = "and";
              rhs = {
                type = "bool";
                value = true;
              };
              type = "boolOp";
            };
            name = "importlib-metadata";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 7 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 8 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "installer";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 4 10 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 5 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "jsonschema";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 23 9 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 24 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "keyring";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 12 2 ];
                };
              }
              {
                cond = "<";
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
            extras = [ ];
            markers = null;
            name = "lockfile";
            url = null;
          }
          {
            conditions = [
              {
                op = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 20 4 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "packaging";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 4 7 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 5 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "pexpect";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 9 4 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "pkginfo";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 5 2 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "platformdirs";
            url = null;
          }
          {
            conditions = [
              {
                cond = "==";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 5 2 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "poetry-core";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 3 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "poetry-plugin-export";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 0 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "pyproject-hooks";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 7 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 4 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "python";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 18 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "requests";
            url = null;
          }
          {
            conditions = [
              {
                op = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 9 1 ];
                };
              }
              {
                op = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 11 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "requests-toolbelt";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 5 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "shellingham";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 1 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 3 0 0 ];
                };
              }
            ];
            extras = [ ];
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
                    release = [ 3 11 ];
                  };
                };
                type = "compare";
              };
              op = "and";
              rhs = {
                type = "bool";
                value = true;
              };
              type = "boolOp";
            };
            name = "tomli";
            url = null;
          }
          {
            conditions = [
              {
                op = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 11 1 ];
                };
              }
              {
                op = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 0 0 ];
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
                  release = [ 0 11 2 ];
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
                  release = [ 0 11 3 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "tomlkit";
            url = null;
          }
          {
            conditions = [
              {
                op = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2022 5 19 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "trove-classifiers";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 1 26 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 2 0 0 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "urllib3";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 20 4 3 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 21 0 0 ];
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
                  release = [ 20 4 5 ];
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
                  release = [ 20 4 6 ];
                };
              }
            ];
            extras = [ ];
            markers = null;
            name = "virtualenv";
            url = null;
          }
          {
            conditions = [
              {
                op = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 20 16 6 ];
                };
              }
            ];
            extras = [ ];
            markers = {
              lhs = {
                lhs = {
                  type = "variable";
                  value = "sys_platform";
                };
                op = "==";
                rhs = {
                  type = "string";
                  value = "win32";
                };
                type = "compare";
              };
              op = "and";
              rhs = {
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
                    release = [ 3 9 ];
                  };
                };
                type = "compare";
              };
              type = "boolOp";
            };
            name = "virtualenv";
            url = null;
          }
          {
            conditions = [
              {
                cond = ">=";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 10 0 ];
                };
              }
              {
                cond = "<";
                version = {
                  dev = null;
                  epoch = 0;
                  local = null;
                  post = null;
                  pre = null;
                  release = [ 0 11 0 ];
                };
              }
            ];
            extras = [ ];
            markers = {
              lhs = {
                type = "variable";
                value = "sys_platform";
              };
              op = "==";
              rhs = {
                type = "string";
                value = "darwin";
              };
              type = "compare";
            };
            name = "xattr";
            url = null;
          }
        ];
        extras = {
          dev = [
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 2 6 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pre-commit";
              url = null;
            }
          ];
          github-actions = [
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 0 1 7 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 0 2 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pytest-github-actions-annotate-failures";
              url = null;
            }
          ];
          test = [
            {
              conditions = [
                {
                  cond = "==";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "cachy";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 6 2 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 7 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "deepdiff";
              url = null;
            }
            {
              conditions = [
                {
                  op = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 6 2 3 ];
                  };
                }
              ];
              extras = [ ];
              markers = {
                lhs = {
                  type = "variable";
                  value = "platform_system";
                };
                op = "==";
                rhs = {
                  type = "string";
                  value = "FreeBSD";
                };
                type = "compare";
              };
              name = "deepdiff";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 1 0 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 2 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "httpretty";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 7 1 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 8 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pytest";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 5 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pytest-cov";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 9 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pytest-mock";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 12 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "pytest-randomly";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 1 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
              ];
              extras = [ "psutil" ];
              markers = null;
              name = "pytest-xdist";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 3 4 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
              ];
              extras = [ ];
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
                      release = [ 3 8 ];
                    };
                  };
                  type = "compare";
                };
                op = "and";
                rhs = {
                  type = "bool";
                  value = true;
                };
                type = "boolOp";
              };
              name = "zipp";
              url = null;
            }
          ];
          typing = [
            {
              conditions = [
                {
                  op = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 1 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "mypy";
              url = null;
            }
            {
              conditions = [
                {
                  op = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 1 1 9 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "types-html5lib";
              url = null;
            }
            {
              conditions = [
                {
                  op = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 9 0 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "types-jsonschema";
              url = null;
            }
            {
              conditions = [
                {
                  op = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 2 28 8 ];
                  };
                }
              ];
              extras = [ ];
              markers = null;
              name = "types-requests";
              url = null;
            }
            {
              conditions = [
                {
                  cond = ">=";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 4 0 0 ];
                  };
                }
                {
                  cond = "<";
                  version = {
                    dev = null;
                    epoch = 0;
                    local = null;
                    post = null;
                    pre = null;
                    release = [ 5 0 0 ];
                  };
                }
              ];
              extras = [ ];
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
                      release = [ 3 8 ];
                    };
                  };
                  type = "compare";
                };
                op = "and";
                rhs = {
                  type = "bool";
                  value = true;
                };
                type = "boolOp";
              };
              name = "typing-extensions";
              url = null;
            }
          ];
        };
      };
    };
  };
}
