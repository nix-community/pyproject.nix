# Setup hook to use for PEP-621/setuptools builds
echo "Sourcing pyproject-build-hook"

pyprojectPypaBuildPhase() {
  echo "Executing pyprojectPypaBuildPhase"
  runHook preBuild

  echo "Creating a wheel..."
  env PYTHONPATH="${NIX_PYPROJECT_PYTHONPATH}:${PYTHONPATH}" @build@/bin/pyproject-build --no-isolation --outdir dist/ --wheel $pypaBuildFlags

  runHook postBuild
  echo "Finished executing pyprojectPypaBuildPhase"
}

if [ -z "${dontUsePyprojectPypaBuild-}" ] && [ -z "${buildPhase-}" ]; then
  echo "Using pyprojectPypaBuildPhase"
  buildPhase=pyprojectPypaBuildPhase
fi
