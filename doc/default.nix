{ stdenv
, nixdoc
, self
, python3
, mdbook
, mdbook-open-on-gh
}:

stdenv.mkDerivation {
  pname = "pyproject-nix-docs-html";
  version = "0.1";
  src = self;
  sourceRoot = "source/doc";
  nativeBuildInputs = [
    python3
    nixdoc
    mdbook
    mdbook-open-on-gh
  ];

  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    mdbook build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv book $out
    runHook postInstall
  '';
}
