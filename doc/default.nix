{ stdenv
, nixdoc
, self
, python3
, mdbook
, mdbook-open-on-gh
, git
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
    git
  ];

  dontConfigure = true;
  dontFixup = true;

  env.RUST_BACKTRACE = 1;

  buildPhase = ''
    runHook preBuild
    chmod +w ../ && mkdir ../.git  # Trick open-on-gh to find the git root
    mdbook build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv book $out
    runHook postInstall
  '';
}
