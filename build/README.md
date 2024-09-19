# Pyproject.nix build infrastructure

Pyproject.nix can be used with nixpkgs `buildPythonPackage`/`packageOverrides`/`withPackages`, but also implements it's own build infrastructure.
It is experimental, and mainly targeted at expert users such as 2nix authors. If you're looking for packaging guidance you're in the wrong place.

This fixes many problems existing in the Nixpkgs Python infrastructure such as:

    No dependency propagation

No leaking of dependencies via PYTHONPATH

    No runtime deps at build time

This causes much less rebuilds

    Support for circular dependencies

    No wrapping of Python bin's

No strange venv breaking shell wrapper

    Proper virtualenvs only

Meaning that applications that spawns children using sys.executable works fine.

    Hermetic bootstrap

Nixpkgs breaks if you override any bootstrap dependencies with wheels.

    Manual cross splicing

Meaning you can override build-time and runtime deps separately.
