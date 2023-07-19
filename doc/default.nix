{ stdenv
, src ? ../.
, nixdoc
, nixpkgs-fmt
, pythonEnv
}:

stdenv.mkDerivation {
  pname = "pyproject-nix-docs-html";
  version = "0.1";
  inherit src;
  sourceRoot = "source/doc";
  nativeBuildInputs = [ pythonEnv nixdoc nixpkgs-fmt ];
  preBuild = "patchShebangs build_md.py";
  installPhase = ''
    runHook preInstall
    cp -a _build/html $out
    runHook postInstall
  '';
}
