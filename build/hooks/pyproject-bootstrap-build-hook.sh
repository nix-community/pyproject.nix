# Setup hook to use for PEP-621/setuptools builds
echo "Sourcing pyproject-build-hook"

pyprojectBuildPhase() {
  echo "Executing pyprojectBuildPhase"
  runHook preBuild

  echo "Creating a wheel..."
  @build@/bin/pyproject-build --no-isolation --outdir dist/ --wheel $pyprojectBuildFlags
  echo "Finished creating a wheel..."

  runHook postBuild
  echo "Finished executing pyprojectBuildPhase"
}

if [ -z "${dontUsePyprojectBuild-}" ] && [ -z "${buildPhase-}" ]; then
  echo "Using pyprojectBuildPhase"
  buildPhase=pyprojectBuildPhase
fi
