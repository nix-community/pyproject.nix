#!/usr/bin/env python
import argparse
from pathlib import Path
from stat import S_ISDIR, S_ISLNK, S_ISREG
from typing import Union


class ArgsNS(argparse.Namespace):
    venv: str
    base: str
    out: str

    def __init__(self):
        self.venv = ""
        self.base = ""
        self.out = ""
        super().__init__()


arg_parser = argparse.ArgumentParser()
arg_parser.add_argument("--venv", required=True)
arg_parser.add_argument("--base", help="Derivation output to use as structure template", required=True)
arg_parser.add_argument("--out", required=True)


DirectoryStructure = Union[Path, dict[str, "DirectoryStructure"]]


def get_structure(root: Path) -> DirectoryStructure:
    """Get structure from package"""
    st_mode = root.lstat().st_mode

    if S_ISDIR(st_mode):
        return {child.name: get_structure(child) for child in root.iterdir()}

    elif S_ISLNK(st_mode):
        return get_structure(root.resolve())

    elif S_ISREG(st_mode):
        return root

    else:
        raise ValueError(f"Unsupported file type for {root}")


def relink_structure(base: Path, venv: Path, ds: DirectoryStructure) -> DirectoryStructure:
    """Relink structure from base to venv"""
    if isinstance(ds, dict):
        return {name: relink_structure(base, venv, value) for name, value in ds.items()}
    else:
        return Path(str(ds).replace(str(base), str(venv)))


def write_structure(root: Path, ds: DirectoryStructure):
    """Write out directory structure"""
    if isinstance(ds, dict):
        root.mkdir()
        for name, value in ds.items():
            write_structure(root.joinpath(name), value)
    else:
        root.symlink_to(ds)


if __name__ == "__main__":
    args = arg_parser.parse_args(namespace=ArgsNS)

    base = Path(args.base)
    venv = Path(args.venv)
    out = Path(args.out)

    base_struct = get_structure(base)
    venv_struct = relink_structure(base, venv, base_struct)

    write_structure(out, venv_struct)
