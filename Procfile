pytest: ptw --ext py,nix -- -W ignore::DeprecationWarning --workers auto
statix: reflex -r '\.nix$' -- statix check
deadnix: reflex -r '\.nix$' -- deadnix
ruff: ruff check --watch .
mypy: reflex -r '\.py$' -- mypy --strict .
