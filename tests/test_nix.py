import json
import subprocess
from typing import (
    Any,
    Iterator,
    List,
)

import pytest
from deepdiff import DeepDiff


def nix_eval(attr: str) -> Any:
    cmd: List[str] = [
        "nix-instantiate",
        "--eval",
        "--strict",
        "--json",
        "--extra-experimental-features",
        "nix-command flakes",
        "./tests/",
        "-A",
        attr,
    ]
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, check=True, stderr=subprocess.PIPE)
    return json.loads(proc.stdout)


def gen_checks() -> Iterator[str]:
    """Get sub attributes of flake attribute libChecks to generate tests"""
    proc = subprocess.run(
        [
            "nix-instantiate",
            "--eval",
            "--strict",
            "--json",
            "--extra-experimental-features",
            "nix-command flakes",
            "./tests/",
            "-A",
            "discovery",
        ],
        check=True,
        stdout=subprocess.PIPE,
    )
    for module_name, suites in json.loads(proc.stdout).items():
        for suite_name, attrs in suites.items():
            for attr in attrs:
                yield f"{module_name}.{suite_name}.{attr}"


@pytest.mark.parametrize("check", gen_checks())
def test_attrs(check: str) -> None:
    """Automatically generate pytest tests from Nix attribute set"""
    result = nix_eval(f"tests.{check}")
    assert DeepDiff(result["output"], result["expected"]).pretty() == ""
