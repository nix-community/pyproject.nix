pyprojectCrossShebangHook() {
  @pythonInterpreter@ @script@ @hostInterpreter@
}

if [ -z "${dontUsePyprojectCrossShebangHook-}" ]; then
  preFixupPhases+=" pyprojectCrossShebangHook"
fi
