# Pyproject.nix - Nix tooling for pyproject.toml projects

Pyproject.nix is a collection of Nix utilities to work with [PEP-621](https://peps.python.org/pep-0621/) compliant `pyproject.toml` files and data formats.

You can think of it as a spiritual successor to [poetry2nix](https://github.com/nix-community/poetry2nix) that puts more of a focus on lower level plumbing and that aims to work with a plethora of package managers.

### Design goals

- Provide low level plumbing that is useful in other projects like [poetry2nix](https://github.com/nix-community/poetry2nix) & [dream2nix](https://github.com/nix-community/dream2nix).

- Flexible overlays

Mix packages from nixpkgs & package manager lock files à la carte.

- Suport for many package managers

Any package manager that supports PEP-621 is a possible target.

### Roadmap

- Python metadata support
  - [x] [PEP 427](https://peps.python.org/pep-0427/) – The Wheel Binary Package Format 1.0
  - [x] [PEP 440](https://peps.python.org/pep-0440/) – Version Identification and Dependency Specification
  - [x] [PEP 508](https://peps.python.org/pep-0508/) – Dependency specification for Python Software Packages
  - [x] [PEP 518](https://peps.python.org/pep-0518/) – Specifying Minimum Build System Requirements for Python Projects
  - [x] [PEP 599](https://peps.python.org/pep-0599/) – The manylinux2014 Platform Tag
  - [x] [PEP 600](https://peps.python.org/pep-0600/) - Future ‘manylinux’ Platform Tags for Portable Linux Built Distributions
  - [x] [PEP 621](https://peps.python.org/pep-0621/) - Storing project metadata in pyproject.toml
- Lock file support
  - [ ] [PDM](https://github.com/pdm-project/pdm)

### Docs

https://adisbladis.github.io/pyproject.nix/

### Matrix chat

https://matrix.to/#/#pyproject.nix:blad.is
