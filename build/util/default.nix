{ runCommand, python3 }:

{

  /**
    Build applications without venv cruft.

    Virtual environments contains many files that are not relevant when
    distributing applications.
    This includes, but is not limited to
    - Python interpreter
    - Activation scripts
    - `pyvenv.cfg`

    This helper creates a new derivation, only symlinking venv files relevant for the application.

    # Example

    ```nix
    util.mkApplication {
      venv = pythonSet.mkVirtualEnv "mkApplication-check-venv" {
        pip = [ ];
      }
      from = pythonSet.pip;
    }
    =>
    «derivation /nix/store/i60rydd6sagcgrsz9cx0la30djzpa8k9-mkApplication-check.drv»
    ```

    # Type

    ```
    mkApplication :: AttrSet -> derivation
    ```

    # Arguments

    venv
    : Virtualenv derivation created using `mkVirtualEnv`

    from
    : Python set package
  */
  mkApplication =
    {
      venv,
      from,
      pname ? from.pname,
      version ? from.version,
    }:
    runCommand "${pname}-${version}"
      {
        inherit (from)
          name
          pname
          version
          meta
          passthru
          ;
        nativeBuildInputs = [
          python3
        ];
      }
      ''
        python3 ${./mk-application.py} --venv ${venv} --base ${from} --out "$out"
      '';

}
