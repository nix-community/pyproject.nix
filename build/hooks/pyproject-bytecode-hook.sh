pyprojectBytecodePhase() {
  if [ -d "$out/bin" ]; then
    rm -rf "$out/bin/__pycache__"                 # Python 3
    find "$out/bin" -type f -name "*.pyc" -delete # Python 2
  fi

  items="$(find "$out" -name "@bytecodeName@")"
  if [[ -n $items ]]; then
    for pycache in $items; do
      rm -rf "$pycache"
    done
  fi

  @pythonInterpreter@ -OO -m compileall @compileArgs@ "$out"/@pythonSitePackages@
}

if [ -z "${dontUsePyprojectBytecode-}" ]; then
  postPhases+=" pyprojectBytecodePhase"
fi
