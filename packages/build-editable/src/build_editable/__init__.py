import argparse
import os
import os.path
import tempfile
from pathlib import Path

import pyproject_hooks
import tomllib

argparser = argparse.ArgumentParser(
    description="Trigger in-place builds required for building editable packages with native extensions"
)
_ = argparser.add_argument(
    "--wheel-dir",
    help="Output wheel to directory instead of a temporary directory that gets immediately deleted",
    type=str,
)


def main() -> None:
    args = argparser.parse_args()

    cwd = Path(os.getcwd())
    if args.wheel_dir is not None:
        out: str = str(args.wheel_dir)
    else:
        out_temp = tempfile.TemporaryDirectory()
        out = out_temp.name

    with open(cwd.joinpath("pyproject.toml"), "rb") as pyproject_file:
        pyproject = tomllib.load(pyproject_file)

    # Get build backend with fallback behaviour
    # https://pip.pypa.io/en/stable/reference/build-system/pyproject-toml/#fallback-behaviour
    try:
        build_backend: str = pyproject["build-system"]["build-backend"]
    except KeyError:
        build_backend = "setuptools.build_meta:__legacy__"

    # Call editable build hooks using pyproject-hooks
    hook_caller = pyproject_hooks.BuildBackendHookCaller(
        source_dir=cwd,
        build_backend=build_backend,
    )
    hook_caller.build_editable(out)


if __name__ == "__main__":
    main()
