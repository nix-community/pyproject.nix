{
  build-system = {
    build-backend = "pdm.backend";
    requires = [
      {
        conditions = [ ];
        markers = null;
        name = "pdm-backend";
        extras = [ ];
        url = null;
      }
    ];
  };
  project = {
    authors = [
      {
        email = "mianghong@gmail.com";
        name = "Frost Ming";
      }
    ];
    classifiers = [ "Topic :: Software Development :: Build Tools" "Programming Language :: Python :: 3" "Programming Language :: Python :: 3.7" "Programming Language :: Python :: 3.8" "Programming Language :: Python :: 3.9" "Programming Language :: Python :: 3.10" "Programming Language :: Python :: 3.11" ];
    dependencies = [
      {
        conditions = [ ];
        markers = null;
        name = "blinker";
        extras = [ ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "certifi";
        extras = [ ];
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
        markers = null;
        name = "packaging";
        extras = [ ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "platformdirs";
        extras = [ ];
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
              release = [ 12 3 0 ];
            };
          }
        ];
        markers = null;
        name = "rich";
        extras = [ ];
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
              release = [ 20 ];
            };
          }
        ];
        markers = null;
        name = "virtualenv";
        extras = [ ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "pyproject-hooks";
        extras = [ ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "requests-toolbelt";
        extras = [ ];
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
              release = [ 0 10 0 ];
            };
          }
        ];
        markers = null;
        name = "unearth";
        extras = [ ];
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
              release = [ 0 3 0 ];
            };
          }
          {
            op = "<";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = {
                type = "a";
                value = 0;
              };
              release = [ 1 0 0 ];
            };
          }
        ];
        markers = null;
        name = "findpython";
        extras = [ ];
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
              release = [ 1 ];
            };
          }
        ];
        markers = null;
        name = "tomlkit";
        extras = [ ];
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
              release = [ 1 3 2 ];
            };
          }
        ];
        markers = null;
        name = "shellingham";
        extras = [ ];
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
              release = [ 0 15 ];
            };
          }
        ];
        markers = null;
        name = "python-dotenv";
        extras = [ ];
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
              release = [ 1 0 1 ];
            };
          }
        ];
        markers = null;
        name = "resolvelib";
        extras = [ ];
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
              release = [ 0 8 ];
            };
          }
          {
            op = ">=";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 0 7 ];
            };
          }
        ];
        markers = null;
        name = "installer";
        extras = [ ];
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
              release = [ 0 13 0 ];
            };
          }
        ];
        markers = null;
        name = "cachecontrol";
        extras = [ "filecache" ];
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
              release = [ 5 ];
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
              release = [ 3 9 ];
            };
          };
          type = "compare";
        };
        name = "importlib-resources";
        extras = [ ];
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
              release = [ 3 6 ];
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
              release = [ 3 10 ];
            };
          };
          type = "compare";
        };
        name = "importlib-metadata";
        extras = [ ];
        url = null;
      }
    ];
    description = "A modern Python package and dependency manager supporting the latest PEP standards";
    dynamic = [ "version" ];
    keywords = [ "packaging" "dependency" "workflow" ];
    license = { text = "MIT"; };
    name = "pdm";
    optional-dependencies = {
      all = [
        {
          conditions = [ ];
          markers = null;
          name = "pdm";
          extras = [ "keyring" "template" "truststore" ];
          url = null;
        }
      ];
      cookiecutter = [
        {
          conditions = [ ];
          markers = null;
          name = "cookiecutter";
          extras = [ ];
          url = null;
        }
      ];
      copier = [
        {
          conditions = [ ];
          markers = null;
          name = "copier";
          extras = [ ];
          url = null;
        }
      ];
      keyring = [
        {
          conditions = [ ];
          markers = null;
          name = "keyring";
          extras = [ ];
          url = null;
        }
      ];
      pytest = [
        {
          conditions = [ ];
          markers = null;
          name = "pytest";
          extras = [ ];
          url = null;
        }
        {
          conditions = [ ];
          markers = null;
          name = "pytest-mock";
          extras = [ ];
          url = null;
        }
      ];
      template = [
        {
          conditions = [ ];
          markers = null;
          name = "pdm";
          extras = [ "copier" "cookiecutter" ];
          url = null;
        }
      ];
      truststore = [
        {
          conditions = [ ];
          markers = {
            lhs = {
              type = "variable";
              value = "python_version";
            };
            op = ">=";
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
          name = "truststore";
          extras = [ ];
          url = null;
        }
      ];
    };
    readme = "README.md";
    requires-python = {
      op = ">=";
      version = {
        dev = null;
        epoch = 0;
        local = null;
        post = null;
        pre = null;
        release = [ 3 7 ];
      };
    };
    scripts = { pdm = "pdm.core:main"; };
    urls = {
      Changelog = "https://pdm.fming.dev/latest/dev/changelog/";
      Documentation = "https://pdm.fming.dev";
      Homepage = "https://pdm.fming.dev";
      Repository = "https://github.com/pdm-project/pdm";
    };
  };
  tool = {
    black = {
      line-length = 120;
      target-version = [ "py37" "py38" "py39" "py310" ];
    };
    pdm = {
      build = {
        editable-backend = "path";
        excludes = [ "./**/.git" ];
        includes = [ "src/pdm" ];
        package-dir = "src";
        source-includes = [ "tests" "CHANGELOG.md" "LICENSE" "README.md" ];
      };
      dev-dependencies = {
        doc = [ "mkdocs>=1.1" "mkdocs-material>=7.3" "mkdocstrings[python]>=0.18" "mike>=1.1.2" "setuptools>=62.3.3" "markdown-exec>=0.7.0" "mkdocs-redirects>=1.2.0" ];
        test = [ "pdm[pytest]" "pytest-cov" "pytest-xdist>=1.31.0" "pytest-rerunfailures>=10.2" "pytest-httpserver>=1.0.6" ];
        tox = [ "tox" "tox-pdm>=0.5" ];
        workflow = [ "pdm-pep517>=1.0.0,<2.0.0" "parver>=0.3.1" "towncrier>=20" "pycomplete~=0.3" ];
      };
      scripts = {
        complete = {
          call = "tasks.complete:main";
          help = "Create autocomplete files for bash and fish";
        };
        doc = {
          help = "Start the dev server for doc preview";
          shell = "cd docs && mkdocs serve";
        };
        lint = "pre-commit run --all-files";
        pre_release = "python tasks/max_versions.py";
        release = "python tasks/release.py";
        test = "pytest";
        tox = "tox";
      };
      version = {
        source = "scm";
        write_to = "pdm/models/VERSION";
      };
    };
    pytest = {
      ini_options = {
        addopts = "-r aR";
        filterwarnings = [ "ignore::DeprecationWarning" ];
        markers = [ "network: Tests that require network" "integration: Run with all Python versions" "path: Tests that compare with the system paths" "deprecated: Tests about deprecated features" ];
        testpaths = [ "tests/" ];
      };
    };
    ruff = {
      exclude = [ "tests/fixtures" ];
      extend-ignore = [ "B018" "B019" ];
      extend-select = [ "I" "B" "C4" "PGH" "RUF" "W" "YTT" ];
      isort = { known-first-party = [ "pdm" ]; };
      line-length = 120;
      mccabe = { max-complexity = 10; };
      src = [ "src" ];
      target-version = "py37";
    };
    towncrier = {
      directory = "news/";
      filename = "CHANGELOG.md";
      issue_format = "[#{issue}](https://github.com/pdm-project/pdm/issues/{issue})";
      package = "pdm";
      template = "news/towncrier_template.md";
      title_format = "Release v{version} ({project_date})";
      type = [
        {
          directory = "break";
          name = "Breaking Changes";
          showcontent = true;
        }
        {
          directory = "feature";
          name = "Features & Improvements";
          showcontent = true;
        }
        {
          directory = "bugfix";
          name = "Bug Fixes";
          showcontent = true;
        }
        {
          directory = "doc";
          name = "Documentation";
          showcontent = true;
        }
        {
          directory = "dep";
          name = "Dependencies";
          showcontent = true;
        }
        {
          directory = "removal";
          name = "Removals and Deprecations";
          showcontent = true;
        }
        {
          directory = "misc";
          name = "Miscellany";
          showcontent = true;
        }
      ];
      underlines = "-~^";
    };
  };
}
