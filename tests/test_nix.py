from typing import (
    Iterator,
    Optional,
    Dict,
    List,
    cast,
    Set,
    Any,
)
import subprocess
import pytest
import json


def assert_deepequals(
    a: Any,
    b: Any,
    ignore_paths: Optional[Set[str]] = None,
    _path: Optional[tuple[str]] = None,
):
    """Compare objects a and b keeping track of object path for error reporting.

    Keyword arguments:
    a -- Object a
    b -- Object b
    ignore_paths -- List of object paths (delimited by .)

    Example:
    assert_deepequals({
        "poetry-version": "1.0.0a3",
        "content-hash": "example",
    }, {
      "metadata": {
        "poetry-version": "1.0.0a4",
        "content-hash": "example",
      }
    }, ignore_paths=set(["metadata.poetry-version"]))
    """

    _path = cast(tuple[str], (_path if _path else tuple()))
    ignore_paths = ignore_paths if ignore_paths else set()
    path = ".".join(_path)
    err = ValueError("{}: {} != {}".format(path, a, b))

    def make_path(entry):
        return _path + (str(entry),)

    if isinstance(a, list):
        if not isinstance(b, list) or len(a) != len(b):
            raise err

        for vals in zip(a, b):
            p = make_path("[]")
            if ".".join(p) not in ignore_paths:
                assert_deepequals(*vals, _path=p, ignore_paths=ignore_paths)

    elif isinstance(a, dict):
        if not isinstance(b, dict):
            raise err

        for key in set(a.keys()) | set(b.keys()):
            p = make_path(key)
            if ".".join(p) not in ignore_paths:
                assert_deepequals(a[key], b[key], _path=p, ignore_paths=ignore_paths)

    elif a == b:
        return

    else:
        raise err


def nix_eval(attr: str) -> Dict:
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
    proc = subprocess.run(
        cmd, stdout=subprocess.PIPE, check=True, stderr=subprocess.PIPE
    )
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
def test_attrs(check) -> None:
    """Automatically generate pytest tests from Nix attribute set"""
    result = nix_eval(f"tests.{check}")
    assert_deepequals(result["output"], result["expected"])
