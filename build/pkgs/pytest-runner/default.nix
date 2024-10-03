{
  stdenv,
  fetchurl,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  pname = "pytest-runner";
  version = "6.0.1";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/d7/7d/60976d532519c3a0b41e06a59ad60949e2be1af937cf02738fec91bfd808/pytest-runner-6.0.1.tar.gz";
    hash = "sha256-cNRzlYWnAI83v0kzwBP9sye4h4paafy7MxbIiILw9Js=";
  };

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      setuptools = [ ];
      setuptools-scm = [ ];
    };
}
