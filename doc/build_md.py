#!/usr/bin/env python
import os
import os.path
import re
import subprocess
import sys

# Build markdown from Nix files using Nixdoc and apply some post-processing
# Sphinx doesn't seem to support everything we need so let's patch it away until we can fix that.

if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    output_dir = os.path.dirname(os.path.abspath(output_file))

    module = os.path.splitext(os.path.basename(input_file))[0]

    proc = subprocess.run(
        [
            "nixdoc",
            "--category",
            module,
            "--description",
            module,
            "--file",
            input_file,
        ],
        check=True,
        stdout=subprocess.PIPE,
    )

    # Remove trailing "anchors" (is this what they're called?)
    lines: list[str] = []
    for line in proc.stdout.decode().splitlines():
        if line.startswith("# ") or line.startswith("## ") or line.startswith("::: "):
            if m := re.match(r"(^.+) \{.+$", line):
                line = m.group(1)
        lines.append(line)

    try:
        os.mkdir(output_dir)
    except FileExistsError:
        pass

    with open(output_file, "w") as f:
        f.write("\n".join(lines))
        f.write("")
