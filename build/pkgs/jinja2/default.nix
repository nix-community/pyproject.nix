{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.jinja2)
    pname
    version
    src
    meta
    ;

  passthru = {
    dependencies = {
      markupsafe = [ ];
    };

    optional-dependencies = {
      i18n = {
        babel = [ ];
      };
    };
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
