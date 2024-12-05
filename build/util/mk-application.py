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


DirectoryStructure = Union[None, dict[str, "DirectoryStructure"]]


SKIP_PATTERNS = (
    ("nix-support",),
    (
        "lib",
        None,
        "site-packages",
    ),
)


def do_skip(stack: tuple[str, ...]) -> bool:
    """Check if a stack matches a skip pattern"""
    for pattern in SKIP_PATTERNS:
        if len(stack) != len(pattern):
            continue

        for tpl, tok in zip(pattern, stack):
            if tpl is None:
                continue
            if tpl != tok:
                break
        else:
            return True

    return False


def get_structure(root: Path) -> DirectoryStructure:
    """Get structure from package"""

    def recurse(stack: tuple[str, ...], root: Path) -> DirectoryStructure:
        st_mode = root.lstat().st_mode

        if S_ISDIR(st_mode):
            ret: DirectoryStructure = {}

            for child in root.iterdir():
                # Check if the current tree position is a skipped node
                stack_child = (*stack, child.name)
                if do_skip(stack):
                    continue

                # Traverse into child
                structure = recurse(stack_child, child)

                # Append to output structure if result is file or non-empty directory.
                # Note that the child may have been filtered by a skipped node,
                # and may be returned as empty even if the directory is not.
                if structure is None or structure:
                    ret[child.name] = structure

            return ret

        elif S_ISREG(st_mode):
            return None

        # An input file may be a symlink if created by hacks.nixpkgsPrebuilt or if created by an override
        # We still want to traverse into this symlink to copy it's structure to the output.
        elif S_ISLNK(st_mode):
            return recurse(stack, root.resolve())

        else:
            raise ValueError(f"Unsupported file type for {root}")

    return recurse((), root)


def write_structure(
    structure: DirectoryStructure,
    venv: Path,
    out: Path,
):
    """Write out directory structure"""

    def recurse(ds: DirectoryStructure, stack: tuple[str, ...]):
        dst = out.joinpath(*stack)
        if isinstance(ds, dict):
            dst.mkdir()
            for name, value in ds.items():
                recurse(value, (*stack, name))
        else:
            target = venv.joinpath(*stack)

            # Target may not exist because it's filtered by the venv creation script.
            if target.exists():
                dst.symlink_to(target)

    recurse(structure, ())


def main():
    args = arg_parser.parse_args(namespace=ArgsNS)

    base = Path(args.base)
    venv = Path(args.venv)
    out = Path(args.out)

    structure = get_structure(base)
    write_structure(structure, venv, out)


if __name__ == "__main__":
    main()
