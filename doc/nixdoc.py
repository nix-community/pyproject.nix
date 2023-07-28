#!/usr/bin/env python3
# An mdBook preprocessor that puts Nix files through Nixdoc
import json
import os.path
import subprocess
import sys

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports":
            sys.exit(0)

    context, book = json.load(sys.stdin)

    for section in book["sections"]:
        try:
            chapter = section["Chapter"]
        except KeyError:
            continue

        _, ext = os.path.splitext(chapter["source_path"])
        if ext != ".nix":
            continue

        proc = subprocess.run(
            [
                "nixdoc",
                "--category",
                chapter["name"],
                "--description",
                chapter["name"],
                "--file",
                "/dev/stdin",
            ],
            check=True,
            stdout=subprocess.PIPE,
            input=chapter["content"].encode(),
        )
        chapter["content"] = proc.stdout.decode()

    print(json.dumps(book))
