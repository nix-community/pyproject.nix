{
  build-system = {
    build-backend = "mesonpy";
    requires = [
      {
        conditions = [
          {
            op = "==";
            version = {
              dev = null;
              epoch = 0;
              local = null;
              post = null;
              pre = null;
              release = [ 0 13 1 ];
            };
          }
        ];
        markers = null;
        name = "meson-python";
        extras = [ ];
        url = null;
      }
      {
        conditions = [
          {
            op = "==";
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
        name = "meson";
        extras = [ "ninja" ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "wheel";
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
              release = [ 0 29 33 ];
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
              release = [ 3 ];
            };
          }
        ];
        markers = null;
        name = "Cython";
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
              release = [ 2022 8 16 ];
            };
          }
        ];
        markers = null;
        name = "oldest-supported-numpy";
        extras = [ ];
        url = null;
      }
      {
        conditions = [ ];
        markers = null;
        name = "versioneer";
        extras = [ "toml" ];
        url = null;
      }
    ];
  };
  project = {
    authors = [
      {
        email = "pandas-dev@python.org";
        name = "The Pandas Development Team";
      }
    ];
    classifiers = [ "Development Status :: 5 - Production/Stable" "Environment :: Console" "Intended Audience :: Science/Research" "License :: OSI Approved :: BSD License" "Operating System :: OS Independent" "Programming Language :: Cython" "Programming Language :: Python" "Programming Language :: Python :: 3" "Programming Language :: Python :: 3 :: Only" "Programming Language :: Python :: 3.9" "Programming Language :: Python :: 3.10" "Programming Language :: Python :: 3.11" "Topic :: Scientific/Engineering" ];
    dependencies = [
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
              release = [ 1 21 6 ];
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
        name = "numpy";
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
              release = [ 1 23 2 ];
            };
          }
        ];
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
              release = [ 3 11 ];
            };
          };
          type = "compare";
        };
        name = "numpy";
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
              release = [ 2 8 2 ];
            };
          }
        ];
        markers = null;
        name = "python-dateutil";
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
              release = [ 2020 1 ];
            };
          }
        ];
        markers = null;
        name = "pytz";
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
              release = [ 2022 1 ];
            };
          }
        ];
        markers = null;
        name = "tzdata";
        extras = [ ];
        url = null;
      }
    ];
    description = "Powerful data structures for data analysis, time series, and statistics";
    dynamic = [ "version" ];
    entry-points = { pandas_plotting_backends = { matplotlib = "pandas:plotting._matplotlib"; }; };
    license = { file = "LICENSE"; };
    name = "pandas";
    optional-dependencies = {
      all = [
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
                release = [ 4 11 1 ];
              };
            }
          ];
          markers = null;
          name = "beautifulsoup4";
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
                release = [ 1 3 4 ];
              };
            }
          ];
          markers = null;
          name = "bottleneck";
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
                release = [ 0 7 0 ];
              };
            }
          ];
          markers = null;
          name = "brotlipy";
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
                release = [ 0 8 1 ];
              };
            }
          ];
          markers = null;
          name = "fastparquet";
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "fsspec";
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "gcsfs";
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
                release = [ 1 1 ];
              };
            }
          ];
          markers = null;
          name = "html5lib";
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
                release = [ 6 46 1 ];
              };
            }
          ];
          markers = null;
          name = "hypothesis";
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
                release = [ 3 1 2 ];
              };
            }
          ];
          markers = null;
          name = "jinja2";
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
                release = [ 4 8 0 ];
              };
            }
          ];
          markers = null;
          name = "lxml";
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
                release = [ 3 6 1 ];
              };
            }
          ];
          markers = null;
          name = "matplotlib";
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
                release = [ 0 55 2 ];
              };
            }
          ];
          markers = null;
          name = "numba";
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
                release = [ 2 8 0 ];
              };
            }
          ];
          markers = null;
          name = "numexpr";
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
                release = [ 1 4 1 ];
              };
            }
          ];
          markers = null;
          name = "odfpy";
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
                release = [ 3 0 10 ];
              };
            }
          ];
          markers = null;
          name = "openpyxl";
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
                release = [ 0 17 5 ];
              };
            }
          ];
          markers = null;
          name = "pandas-gbq";
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
                release = [ 2 9 3 ];
              };
            }
          ];
          markers = null;
          name = "psycopg2";
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
                release = [ 7 0 0 ];
              };
            }
          ];
          markers = null;
          name = "pyarrow";
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
                release = [ 1 0 2 ];
              };
            }
          ];
          markers = null;
          name = "pymysql";
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
                release = [ 5 15 6 ];
              };
            }
          ];
          markers = null;
          name = "PyQt5";
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
                release = [ 1 1 5 ];
              };
            }
          ];
          markers = null;
          name = "pyreadstat";
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
                release = [ 7 3 2 ];
              };
            }
          ];
          markers = null;
          name = "pytest";
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
                release = [ 2 2 0 ];
              };
            }
          ];
          markers = null;
          name = "pytest-xdist";
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
                release = [ 0 17 0 ];
              };
            }
          ];
          markers = null;
          name = "pytest-asyncio";
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
                release = [ 0 6 1 ];
              };
            }
          ];
          markers = null;
          name = "python-snappy";
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
                release = [ 1 0 9 ];
              };
            }
          ];
          markers = null;
          name = "pyxlsb";
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
                release = [ 2 2 0 ];
              };
            }
          ];
          markers = null;
          name = "qtpy";
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
                release = [ 1 8 1 ];
              };
            }
          ];
          markers = null;
          name = "scipy";
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "s3fs";
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
                release = [ 1 4 36 ];
              };
            }
          ];
          markers = null;
          name = "SQLAlchemy";
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
                release = [ 3 7 0 ];
              };
            }
          ];
          markers = null;
          name = "tables";
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
                release = [ 0 8 10 ];
              };
            }
          ];
          markers = null;
          name = "tabulate";
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
                release = [ 2022 3 0 ];
              };
            }
          ];
          markers = null;
          name = "xarray";
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
                release = [ 2 0 1 ];
              };
            }
          ];
          markers = null;
          name = "xlrd";
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
                release = [ 3 0 3 ];
              };
            }
          ];
          markers = null;
          name = "xlsxwriter";
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
                release = [ 0 17 0 ];
              };
            }
          ];
          markers = null;
          name = "zstandard";
          extras = [ ];
          url = null;
        }
      ];
      aws = [
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "s3fs";
          extras = [ ];
          url = null;
        }
      ];
      clipboard = [
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
                release = [ 5 15 6 ];
              };
            }
          ];
          markers = null;
          name = "PyQt5";
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
                release = [ 2 2 0 ];
              };
            }
          ];
          markers = null;
          name = "qtpy";
          extras = [ ];
          url = null;
        }
      ];
      compression = [
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
                release = [ 0 7 0 ];
              };
            }
          ];
          markers = null;
          name = "brotlipy";
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
                release = [ 0 6 1 ];
              };
            }
          ];
          markers = null;
          name = "python-snappy";
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
                release = [ 0 17 0 ];
              };
            }
          ];
          markers = null;
          name = "zstandard";
          extras = [ ];
          url = null;
        }
      ];
      computation = [
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
                release = [ 1 8 1 ];
              };
            }
          ];
          markers = null;
          name = "scipy";
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
                release = [ 2022 3 0 ];
              };
            }
          ];
          markers = null;
          name = "xarray";
          extras = [ ];
          url = null;
        }
      ];
      excel = [
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
                release = [ 1 4 1 ];
              };
            }
          ];
          markers = null;
          name = "odfpy";
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
                release = [ 3 0 10 ];
              };
            }
          ];
          markers = null;
          name = "openpyxl";
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
                release = [ 1 0 9 ];
              };
            }
          ];
          markers = null;
          name = "pyxlsb";
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
                release = [ 2 0 1 ];
              };
            }
          ];
          markers = null;
          name = "xlrd";
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
                release = [ 3 0 3 ];
              };
            }
          ];
          markers = null;
          name = "xlsxwriter";
          extras = [ ];
          url = null;
        }
      ];
      feather = [
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
                release = [ 7 0 0 ];
              };
            }
          ];
          markers = null;
          name = "pyarrow";
          extras = [ ];
          url = null;
        }
      ];
      fss = [
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "fsspec";
          extras = [ ];
          url = null;
        }
      ];
      gcp = [
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
                release = [ 2022 5 0 ];
              };
            }
          ];
          markers = null;
          name = "gcsfs";
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
                release = [ 0 17 5 ];
              };
            }
          ];
          markers = null;
          name = "pandas-gbq";
          extras = [ ];
          url = null;
        }
      ];
      hdf5 = [
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
                release = [ 3 7 0 ];
              };
            }
          ];
          markers = null;
          name = "tables";
          extras = [ ];
          url = null;
        }
      ];
      html = [
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
                release = [ 4 11 1 ];
              };
            }
          ];
          markers = null;
          name = "beautifulsoup4";
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
                release = [ 1 1 ];
              };
            }
          ];
          markers = null;
          name = "html5lib";
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
                release = [ 4 8 0 ];
              };
            }
          ];
          markers = null;
          name = "lxml";
          extras = [ ];
          url = null;
        }
      ];
      mysql = [
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
                release = [ 1 4 36 ];
              };
            }
          ];
          markers = null;
          name = "SQLAlchemy";
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
                release = [ 1 0 2 ];
              };
            }
          ];
          markers = null;
          name = "pymysql";
          extras = [ ];
          url = null;
        }
      ];
      output_formatting = [
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
                release = [ 3 1 2 ];
              };
            }
          ];
          markers = null;
          name = "jinja2";
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
                release = [ 0 8 10 ];
              };
            }
          ];
          markers = null;
          name = "tabulate";
          extras = [ ];
          url = null;
        }
      ];
      parquet = [
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
                release = [ 7 0 0 ];
              };
            }
          ];
          markers = null;
          name = "pyarrow";
          extras = [ ];
          url = null;
        }
      ];
      performance = [
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
                release = [ 1 3 4 ];
              };
            }
          ];
          markers = null;
          name = "bottleneck";
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
                release = [ 0 55 2 ];
              };
            }
          ];
          markers = null;
          name = "numba";
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
                release = [ 2 8 0 ];
              };
            }
          ];
          markers = null;
          name = "numexpr";
          extras = [ ];
          url = null;
        }
      ];
      plot = [
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
                release = [ 3 6 1 ];
              };
            }
          ];
          markers = null;
          name = "matplotlib";
          extras = [ ];
          url = null;
        }
      ];
      postgresql = [
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
                release = [ 1 4 36 ];
              };
            }
          ];
          markers = null;
          name = "SQLAlchemy";
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
                release = [ 2 9 3 ];
              };
            }
          ];
          markers = null;
          name = "psycopg2";
          extras = [ ];
          url = null;
        }
      ];
      spss = [
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
                release = [ 1 1 5 ];
              };
            }
          ];
          markers = null;
          name = "pyreadstat";
          extras = [ ];
          url = null;
        }
      ];
      sql-other = [
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
                release = [ 1 4 36 ];
              };
            }
          ];
          markers = null;
          name = "SQLAlchemy";
          extras = [ ];
          url = null;
        }
      ];
      test = [
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
                release = [ 6 46 1 ];
              };
            }
          ];
          markers = null;
          name = "hypothesis";
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
                release = [ 7 3 2 ];
              };
            }
          ];
          markers = null;
          name = "pytest";
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
                release = [ 2 2 0 ];
              };
            }
          ];
          markers = null;
          name = "pytest-xdist";
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
                release = [ 0 17 0 ];
              };
            }
          ];
          markers = null;
          name = "pytest-asyncio";
          extras = [ ];
          url = null;
        }
      ];
      xml = [
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
                release = [ 4 8 0 ];
              };
            }
          ];
          markers = null;
          name = "lxml";
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
        release = [ 3 9 ];
      };
    };
    urls = {
      documentation = "https://pandas.pydata.org/docs/";
      homepage = "https://pandas.pydata.org";
      repository = "https://github.com/pandas-dev/pandas";
    };
  };
  tool = {
    black = {
      exclude = "(\n    asv_bench/env\n  | \\.egg\n  | \\.git\n  | \\.hg\n  | \\.mypy_cache\n  | \\.nox\n  | \\.tox\n  | \\.venv\n  | _build\n  | buck-out\n  | build\n  | dist\n  | setup.py\n)\n";
      required-version = "23.3.0";
      target-version = [ "py39" "py310" ];
    };
    cibuildwheel = {
      build-verbosity = "3";
      environment = { LDFLAGS = "-Wl,--strip-all"; };
      macos = {
        archs = "x86_64 arm64";
        test-skip = "*_arm64";
      };
      overrides = [
        {
          before-test = "apk update && apk add musl-locales";
          select = "*-musllinux*";
        }
        {
          select = "*-win*";
          test-command = "";
        }
        {
          environment = { CFLAGS = "-g0"; };
          select = "*-macosx*";
        }
      ];
      skip = "cp36-* cp37-* cp38-* pp* *_i686 *_ppc64le *_s390x *-musllinux_aarch64";
      test-command = "  PANDAS_CI='1' python -c 'import pandas as pd; pd.test(extra_args=[\"-m not clipboard and not single_cpu and not slow and not network and not db\", \"-n 2\"]); pd.test(extra_args=[\"-m not clipboard and single_cpu and not slow and not network and not db\"]);' ";
      test-requires = "hypothesis>=6.46.1 pytest>=7.3.2 pytest-xdist>=2.2.0 pytest-asyncio>=0.17";
      windows = {
        before-build = "pip install delvewheel";
        repair-wheel-command = "delvewheel repair -w {dest_dir} {wheel}";
      };
    };
    codespell = {
      ignore-regex = "https://([\\w/\\.])+";
      ignore-words-list = "blocs, coo, hist, nd, sav, ser, recuse, nin, timere";
    };
    coverage = {
      html = { directory = "coverage_html_report"; };
      report = {
        exclude_lines = [ "pragma: no cover" "def __repr__" "if self.debug" "raise AssertionError" "raise NotImplementedError" "AbstractMethodError" "if 0:" "if __name__ == .__main__.:" "if TYPE_CHECKING:" ];
        ignore_errors = false;
        omit = [ "pandas/_version.py" ];
        show_missing = true;
      };
      run = {
        branch = true;
        omit = [ "pandas/_typing.py" "pandas/_version.py" ];
        plugins = [ "Cython.Coverage" ];
        source = [ "pandas" ];
      };
    };
    isort = {
      combine_as_imports = true;
      force_grid_wrap = 2;
      force_sort_within_sections = true;
      known_dtypes = "pandas.core.dtypes";
      known_post_core = [ "pandas.tseries" "pandas.io" "pandas.plotting" ];
      known_pre_core = [ "pandas._libs" "pandas._typing" "pandas.util._*" "pandas.compat" "pandas.errors" ];
      known_pre_libs = "pandas._config";
      profile = "black";
      sections = [ "FUTURE" "STDLIB" "THIRDPARTY" "PRE_LIBS" "PRE_CORE" "DTYPES" "FIRSTPARTY" "POST_CORE" "LOCALFOLDER" ];
      skip = "pandas/__init__.py";
      skip_glob = "env";
    };
    meson-python = { args = { setup = [ "--vsenv" ]; }; };
    mypy = {
      allow_redefinition = false;
      allow_untyped_globals = false;
      check_untyped_defs = true;
      disallow_any_decorated = false;
      disallow_any_explicit = false;
      disallow_any_expr = false;
      disallow_any_generics = false;
      disallow_any_unimported = false;
      disallow_incomplete_defs = false;
      disallow_subclassing_any = false;
      disallow_untyped_calls = false;
      disallow_untyped_decorators = true;
      disallow_untyped_defs = false;
      enable_error_code = "ignore-without-code";
      explicit_package_bases = false;
      files = [ "pandas" "typings" ];
      follow_imports = "normal";
      follow_imports_for_stubs = false;
      ignore_errors = false;
      ignore_missing_imports = true;
      implicit_reexport = true;
      local_partial_types = false;
      mypy_path = "typings";
      namespace_packages = false;
      no_implicit_optional = true;
      no_silence_site_packages = false;
      no_site_packages = false;
      overrides = [
        {
          check_untyped_defs = false;
          module = [ "pandas.tests.*" "pandas._version" "pandas.io.clipboard" ];
        }
        {
          ignore_errors = true;
          module = [ "pandas.tests.apply.test_series_apply" "pandas.tests.arithmetic.conftest" "pandas.tests.arrays.sparse.test_combine_concat" "pandas.tests.dtypes.test_common" "pandas.tests.frame.methods.test_to_records" "pandas.tests.groupby.test_rank" "pandas.tests.groupby.transform.test_transform" "pandas.tests.indexes.interval.test_interval" "pandas.tests.indexing.test_categorical" "pandas.tests.io.excel.test_writers" "pandas.tests.reductions.test_reductions" "pandas.tests.test_expressions" ];
        }
      ];
      platform = "linux-64";
      python_version = "3.10";
      show_column_numbers = false;
      show_error_codes = true;
      show_error_context = false;
      strict_equality = true;
      strict_optional = true;
      warn_no_return = true;
      warn_redundant_casts = true;
      warn_return_any = false;
      warn_unreachable = false;
      warn_unused_ignores = true;
    };
    pylint = {
      messages_control = {
        disable = [ "bad-mcs-classmethod-argument" "broad-except" "c-extension-no-member" "comparison-with-itself" "consider-using-enumerate" "import-error" "import-outside-toplevel" "invalid-name" "invalid-unary-operand-type" "line-too-long" "no-else-continue" "no-else-raise" "no-else-return" "no-member" "no-name-in-module" "not-an-iterable" "overridden-final-method" "pointless-statement" "redundant-keyword-arg" "singleton-comparison" "too-many-ancestors" "too-many-arguments" "too-many-boolean-expressions" "too-many-branches" "too-many-function-args" "too-many-instance-attributes" "too-many-locals" "too-many-nested-blocks" "too-many-public-methods" "too-many-return-statements" "too-many-statements" "unexpected-keyword-arg" "ungrouped-imports" "unsubscriptable-object" "unsupported-assignment-operation" "unsupported-membership-test" "unused-import" "use-dict-literal" "use-implicit-booleaness-not-comparison" "use-implicit-booleaness-not-len" "wrong-import-order" "wrong-import-position" "redefined-loop-name" "abstract-class-instantiated" "no-value-for-parameter" "undefined-variable" "unpacking-non-sequence" "used-before-assignment" "missing-class-docstring" "missing-function-docstring" "missing-module-docstring" "superfluous-parens" "too-many-lines" "unidiomatic-typecheck" "unnecessary-dunder-call" "unnecessary-lambda-assignment" "consider-using-with" "cyclic-import" "duplicate-code" "inconsistent-return-statements" "redefined-argument-from-local" "too-few-public-methods" "abstract-method" "arguments-differ" "arguments-out-of-order" "arguments-renamed" "attribute-defined-outside-init" "broad-exception-raised" "comparison-with-callable" "dangerous-default-value" "deprecated-module" "eval-used" "expression-not-assigned" "fixme" "global-statement" "invalid-overridden-method" "keyword-arg-before-vararg" "possibly-unused-variable" "protected-access" "raise-missing-from" "redefined-builtin" "redefined-outer-name" "self-cls-assignment" "signature-differs" "super-init-not-called" "try-except-raise" "unnecessary-lambda" "unused-argument" "unused-variable" "using-constant-test" ];
        max-line-length = 88;
      };
    };
    pyright = {
      exclude = [ "pandas/tests" "pandas/io/clipboard" "pandas/util/version" ];
      include = [ "pandas" "typings" ];
      pythonVersion = "3.10";
      reportDuplicateImport = true;
      reportGeneralTypeIssues = false;
      reportInvalidStubStatement = true;
      reportMissingModuleSource = false;
      reportOptionalCall = false;
      reportOptionalIterable = false;
      reportOptionalMemberAccess = false;
      reportOptionalOperand = false;
      reportOptionalSubscript = false;
      reportOverlappingOverload = true;
      reportPrivateImportUsage = false;
      reportPropertyTypeMismatch = true;
      reportUnboundVariable = false;
      reportUntypedClassDecorator = true;
      reportUntypedFunctionDecorator = true;
      reportUntypedNamedTuple = true;
      reportUnusedImport = true;
      typeCheckingMode = "basic";
    };
    pytest = {
      ini_options = {
        addopts = "--strict-data-files --strict-markers --strict-config --capture=no --durations=30 --junitxml=test-data.xml";
        asyncio_mode = "strict";
        doctest_optionflags = [ "NORMALIZE_WHITESPACE" "IGNORE_EXCEPTION_DETAIL" "ELLIPSIS" ];
        empty_parameter_set_mark = "fail_at_collect";
        filterwarnings = [ "error:::pandas" "error::ResourceWarning" "error::pytest.PytestUnraisableExceptionWarning" "ignore:.*ssl.SSLSocket:pytest.PytestUnraisableExceptionWarning" "ignore:.*ssl.SSLSocket:ResourceWarning" "ignore:.*FileIO:pytest.PytestUnraisableExceptionWarning" "ignore:.*BufferedRandom:ResourceWarning" "ignore::ResourceWarning:asyncio" "ignore:More than 20 figures have been opened:RuntimeWarning" "ignore:`np.MachAr` is deprecated:DeprecationWarning:numba" "ignore:.*urllib3:DeprecationWarning:botocore" "ignore:Setuptools is replacing distutils.:UserWarning:_distutils_hack" "ignore:a closed node found in the registry:UserWarning:tables" "ignore:`np.object` is a deprecated:DeprecationWarning:tables" "ignore:tostring:DeprecationWarning:tables" "ignore:distutils Version classes are deprecated:DeprecationWarning:pandas_datareader" "ignore:distutils Version classes are deprecated:DeprecationWarning:numexpr" "ignore:distutils Version classes are deprecated:DeprecationWarning:fastparquet" "ignore:distutils Version classes are deprecated:DeprecationWarning:fsspec" ];
        junit_family = "xunit2";
        markers = [ "single_cpu: tests that should run on a single cpu only" "slow: mark a test as slow" "network: mark a test as network" "db: tests requiring a database (mysql or postgres)" "clipboard: mark a pd.read_clipboard test" "arm_slow: mark a test as slow for arm64 architecture" "arraymanager: mark a test to run with ArrayManager enabled" ];
        minversion = "7.3.2";
        testpaths = "pandas";
        xfail_strict = true;
      };
    };
    ruff = {
      exclude = [ "doc/sphinxext/*.py" "doc/build/*.py" "doc/temp/*.py" ".eggs/*.py" "pandas/util/version/*" "env" ];
      fix = true;
      ignore = [ "E402" "E731" "B006" "B007" "B008" "B009" "B010" "B011" "B015" "B019" "B020" "B023" "B905" "PLR0913" "PLR0911" "PLR0912" "PLR0915" "PLW2901" "PLW0603" "PYI021" "PGH001" "PLC1901" "B018" "B904" "PLR2004" "PLR0124" "PLR5501" "RUF001" "RUF002" "RUF003" "RUF005" "RUF007" "RUF010" "RUF012" ];
      line-length = 88;
      per-file-ignores = {
        "asv_bench/*" = [ "TID" ];
        "pandas/_typing.py" = [ "TCH" ];
        "pandas/core/*" = [ "PLR5501" ];
        "pandas/tests/*" = [ "B028" ];
        "scripts/*" = [ "B028" ];
      };
      select = [ "F" "E" "W" "YTT" "B" "Q" "T10" "INT" "PLC" "PLE" "PLR" "PLW" "PIE" "PYI" "TID" "ISC" "TCH" "C4" "PGH" "RUF" "S102" ];
      target-version = "py310";
      unfixable = [ ];
    };
    setuptools = {
      exclude-package-data = { "*" = [ "*.c" "*.h" ]; };
      include-package-data = true;
      packages = {
        find = {
          include = [ "pandas" "pandas.*" ];
          namespaces = false;
        };
      };
    };
    versioneer = {
      VCS = "git";
      parentdir_prefix = "pandas-";
      style = "pep440";
      tag_prefix = "v";
      versionfile_build = "pandas/_version.py";
      versionfile_source = "pandas/_version.py";
    };
  };
}
