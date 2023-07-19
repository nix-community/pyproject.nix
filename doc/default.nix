{ stdenv
, nixdoc
, nixpkgs-fmt
, self
, python3
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.sphinx
    ps.myst-parser
    ps.linkify-it-py
    ps.sphinx-rtd-theme
  ]);

in
stdenv.mkDerivation {
  pname = "pyproject-nix-docs-html";
  version = "0.1";
  src = self;
  sourceRoot = "source/doc";
  nativeBuildInputs = [ pythonEnv nixdoc nixpkgs-fmt ];
  preBuild = "patchShebangs build_md.py";
  env.SOURCE_DATE_EPOCH = self.lastModified; # Get a reasonable date in footer
  installPhase = ''
    runHook preInstall
    cp -a _build/html $out
    runHook postInstall
  '';
}
