_: {
  # Used to find the project root
  projectRootFile = "flake.lock";

  # JS/doc
  programs.prettier.enable = true;
  settings.formatter.prettier.excludes = [ "highlight.js" ];

  # Shell
  programs.shellcheck.enable = true;

  # Nix
  programs.deadnix.enable = true;
  programs.statix.enable = true;
  programs.nixpkgs-fmt.enable = true;

  # Python
  programs.black.enable = true;
  programs.ruff.enable = true;
}
