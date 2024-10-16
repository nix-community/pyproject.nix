# Contents

- [Introduction](./introduction.md)

# Use cases

- [Developing with nixpkgs]()
  - [pyproject.toml](./use-cases/pyproject.md)
  - [requirements.txt](./use-cases/requirements.md)

- [Python2nix]()
  - [Builders](./build.md)
    - [Usage](./builders/usage.md)
  - [packages](./builders/packages.md)
  - [overriding packages](./builders/overriding.md)
    - [hacks](./builders/hacks.md)
  - [ecosystem](./builders/ecosystem.md)

# Meta
- [FAQ](./FAQ.md)

# Library reference

- [User facing APIs](./reference.md)
  - [project](./lib/project.nix)
  - [scripts](./lib/scripts.nix)
  - [nixpkgs](./nixpkgs-build.md)
    - [renderers](./lib/renderers.nix)
    - [validators](./lib/validators.nix)
- [Standards APIs](./reference.md)
  - [pep440](./lib/pep440.nix)
  - [pep508](./lib/pep508.nix)
  - [pep518](./lib/pep518.nix)
  - [pep599](./lib/pep599.nix)
  - [pep600](./lib/pep600.nix)
  - [pep621](./lib/pep621.nix)
  - [pep656](./lib/pep656.nix)
  - [pep723](./lib/pep723.nix)
  - [poetry](./lib/poetry.nix)
  - [pypa](./lib/pypa.nix)
  - [eggs](./lib/eggs.nix)
  - [pip](./lib/pip.nix)

- [Build](./build.md)
  - [lib](./build/lib/default.nix)
    - [renderers](./build/lib/renderers.nix)
    - [resolvers](./build/lib/resolvers.nix)
    - [hacks](./build/hacks/default.nix)
  - [hooks](./build/hooks/default.nix)

# Contributing

- [Hacking](./HACKING.md)
