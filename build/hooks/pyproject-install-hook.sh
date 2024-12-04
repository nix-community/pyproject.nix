# Setup hook for Pyproject installer.
echo "Sourcing pyproject-install-hook"

pyprojectInstallPhase() {
  echo "Executing pyprojectInstallPhase"
  runHook preInstall

  pushd dist >/dev/null

  if [ -z "${UV_COMPILE_BYTECODE-}" ]; then
    export UV_COMPILE_BYTECODE=1
  fi

  if [ -z "${UV_NO_INSTALLER_METADATA-}" ]; then
    export UV_NO_INSTALLER_METADATA=1
  fi

  for wheel in ./*.whl; do
    @uv@/bin/uv pip --offline --no-cache install --no-deps --link-mode=copy --python=@pythonInterpreter@ --system --prefix "$out" $uvPipInstallFlags "$wheel"
    echo "Successfully installed $wheel"
  done

  rm -f "$out/.lock"

  popd >/dev/null

  runHook postInstall
  echo "Finished executing pyprojectInstallPhase"
}

if [ -z "${dontUsePyprojectInstall-}" ] && [ -z "${installPhase-}" ]; then
  echo "Using pyprojectInstallPhase"
  installPhase=pyprojectInstallPhase
fi
