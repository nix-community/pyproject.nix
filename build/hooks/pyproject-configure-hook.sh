# Setup hook to use for PEP-621/setuptools builds
echo "Sourcing pyproject-configure-hook"

pyprojectConfigurePhase() {
  echo "Executing pyprojectConfigurePhase"
  runHook preConfigure

  # Undo any Python dependency propagation leaking into build, and set it to our interpreters PYTHONPATH
  #
  # In case of cross compilation this variable will contain two entries:
  # One for the native Python and one for the cross built, so the native can load sysconfig
  # information from the cross compiled Python.
  export PYTHONPATH=@pythonPath@

  runHook postConfigure
  echo "Finished executing pyprojectConfigurePhase"
}

if [ -z "${dontUsePyprojectConfigure-}" ] && [ -z "${configurePhase-}" ]; then
  echo "Using pyprojectConfiguredPhase"
  configurePhase=pyprojectConfigurePhase
fi
