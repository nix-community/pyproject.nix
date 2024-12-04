# Setup hook to use for PEP-621/setuptools builds
echo "Sourcing pyproject-build-hook"

pyprojectBuildPhase() {
  echo "Executing pyprojectBuildPhase"
  runHook preBuild

  echo "Creating a wheel..."
  env PYTHONPATH="${NIX_PYPROJECT_PYTHONPATH}:${PYTHONPATH}" @uv@/bin/uv build -v --no-cache --python=@pythonInterpreter@ --offline --no-build-isolation --out-dir dist/ --wheel $uvBuildFlags

  runHook postBuild
  echo "Finished executing pyprojectBuildPhase"
}

if [ -z "${dontUsePyprojectBuild-}" ] && [ -z "${buildPhase-}" ]; then
  echo "Using pyprojectBuildPhase"
  buildPhase=pyprojectBuildPhase
fi
