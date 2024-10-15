#!/usr/bin/env python3
import argparse
import os
import re
import shutil
import stat
from pathlib import Path

arg_parser = argparse.ArgumentParser(
    description="Adapt a Nixpkgs Python infrastructure package to one that can be consumed by pyproject.nix builders",
)
_ = arg_parser.add_argument("input")
_ = arg_parser.add_argument("output")
_ = arg_parser.add_argument("--store", default="/nix/store")


def write_nix_support(input: Path, output: Path):
    """Write nix-support, skipping propagated inputs"""

    files = [file for file in input.glob("*") if file.name != "propagated-build-inputs"]

    if files:
        output.mkdir()

    for input_file in files:
        output.joinpath(input_file.name).symlink_to(input_file)


def write_bin(store_dir: str, input: Path, output: Path):
    """Write bin while undoing shell script wrappers"""
    output.mkdir()

    paths = {path.name: path for path in input.glob("*")}

    nixpkgs_dep_re = re.compile(r"import sys.+sys.argv\[0\](.+)" + re.escape(store_dir))

    # Replace references to wrappers with their unwrapped equivalents
    for filename in list(paths):
        m = re.match(r"^\.(.+)-wrapped$", filename)
        if not m:
            continue

        unwrapped_name = m.group(1)
        if not isinstance(unwrapped_name, str):
            raise ValueError(f"Unexpected unwrapped name: {unwrapped_name}")

        if unwrapped_name not in paths:
            raise ValueError(f"Unwrapped name was computed as '{unwrapped_name}' but it's not present in input")

        paths[unwrapped_name] = paths[filename]
        del paths[filename]

    for filename, source in paths.items():
        out_bin = output.joinpath(filename)

        st_mode = source.lstat().st_mode

        # If source is a symlink, just copy
        if stat.S_ISLNK(st_mode):
            shutil.copy(source, out_bin, follow_symlinks=False)
            continue

        # First try to read as a Python script, removing lines where Nixpkgs Python builders have added dependencies to sys.path
        try:
            with open(source, "r") as src_file:
                src = src_file.read()
        except UnicodeDecodeError:
            shutil.copy(source, out_bin)
        else:
            with open(out_bin, "w") as out_file:
                for line in src.splitlines(keepends=True):
                    # Match nixpkgs dependency injection preamble and filter out
                    if nixpkgs_dep_re.match(line):
                        continue
                    out_file.write(line)

            os.chmod(out_bin, st_mode)


def main():
    args = arg_parser.parse_args()

    input = Path(args.input)
    output = Path(args.output)

    output.mkdir()

    for root_file in input.glob("*"):
        if root_file.name == "nix-support":
            write_nix_support(root_file, output.joinpath("nix-support"))
            continue

        if root_file.name == "bin":
            write_bin(args.store, root_file, output.joinpath("bin"))
            continue

        output.joinpath(root_file.name).symlink_to(root_file)


if __name__ == "__main__":
    main()
