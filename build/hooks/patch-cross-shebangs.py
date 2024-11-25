#!/usr/bin/env python
import os
import os.path
import sys
from pathlib import Path
from typing import Optional


def main():
    # Output directory
    out_dir = Path(os.environ["out"])
    bin_dir = out_dir.joinpath("bin")

    # Cross python interpreter
    cross_bin = os.path.dirname(sys.executable)
    cross_shebang = f"#!{cross_bin}".encode()

    # Target host interpreter
    host_bin = os.path.dirname(sys.argv[1])
    host_shebang = f"#!{host_bin}".encode()

    if not bin_dir.exists():
        return

    for bin in bin_dir.iterdir():
        script: Optional[bytes] = None

        with bin.open(mode="rb") as fd:
            preamble = fd.read(len(cross_shebang))
            if preamble == cross_shebang:
                script = host_shebang + fd.read()

        if script:
            print(f"Rewriting shebang for '{bin}'")

            with bin.open(mode="wb") as fd:
                fd.write(script)


if __name__ == "__main__":
    main()
