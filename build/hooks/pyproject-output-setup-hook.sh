pyprojectOutputSetupHook() {
  mkdir -p $out/nix-support
  cat >>$out/nix-support/setup-hook <<EOF
# Add Python dependency to search path for discovery by build
addToSearchPath NIX_PYPROJECT_DEPS "$out"
addToSearchPath NIX_PYPROJECT_PYTHONPATH "$out/@pythonSitePackages@"
EOF
}

if [ -z "${dontUsePyprojectOutputSetupHook-}" ]; then
  postPhases+=" pyprojectOutputSetupHook"
fi
