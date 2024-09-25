# Setup hook to use for PEP-621/setuptools builds
echo "Sourcing pyproject-build-hook"

pyprojectBuildPhase() {
  echo "Executing pyprojectBuildPhase"
  runHook preBuild

  echo "Creating a wheel..."
  env PYTHONPATH="${NIX_PYPROJECT_PYTHONPATH}:${PYTHONPATH}" @build@/bin/pyproject-build --no-isolation --outdir dist/ --wheel $pypaBuildFlags

  runHook postBuild
  echo "Finished executing pyprojectBuildPhase"
}

if [ -z "${dontUsePyprojectBuild-}" ] && [ -z "${buildPhase-}" ]; then
  echo "Using pyprojectBuildPhase"
  buildPhase=pyprojectBuildPhase
fi
