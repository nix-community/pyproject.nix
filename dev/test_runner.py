#!/usr/bin/env python
import argparse
import json
import subprocess
from dataclasses import dataclass
from typing import Iterator

from deepdiff import DeepDiff
from pygments import highlight
from pygments.formatters import Terminal256Formatter as TerminalFormatter
from pygments.lexers import JsonLexer

argparser = argparse.ArgumentParser()
argparser.add_argument("--ci-input", help="Path to fully evaluated file (for CI/sandbox use)")


@dataclass
class TestResult:
    attr: str
    result: dict

    @property
    def success(self) -> bool:
        return not bool(DeepDiff(self.result["expected"], self.result["expr"]))


def run_test(test_attr: str) -> TestResult:
    """Run test by evaluating attr"""

    proc = subprocess.run(
        ["nix", "eval", "--json", f".#libTests.{test_attr}"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    if proc.returncode != 0:
        raise ValueError(f"{proc.args} returned {proc.returncode}: {proc.stderr.decode()}")

    return TestResult(attr=test_attr, result=json.loads(proc.stdout))


def print_results(results: Iterator[TestResult]) -> tuple[int, int]:
    """Handle list of results and return a tuple of (successes, total)"""
    lexer = JsonLexer()
    formatter = TerminalFormatter()

    total = 0
    success = 0

    for result in results:
        total += 1
        if result.success:
            success += 1
            print(f"✅ {result.attr}")
        else:
            print(f"❌ {result.attr}")
            print(highlight(json.dumps(result.result, indent=2, sort_keys=True), lexer, formatter))

    return (success, total)


if __name__ == "__main__":
    args = argparser.parse_args()

    if args.ci_input:
        with open(args.ci_input) as f:
            results = (TestResult(attr, result) for attr, result in json.load(f).items())

    else:
        # Separate discovery of attrs from test execution so we can catch eval failures individually
        attrs: list[str] = json.loads(
            subprocess.run(
                ["nix", "eval", "--apply", "builtins.attrNames", "--json", ".#libTests"], stdout=subprocess.PIPE
            ).stdout
        )
        results = (run_test(attr) for attr in attrs)

    success, total = print_results(results)

    print("")
    print(f"{'😀' if success == total else '💀'} {success}/{total} successful")

    if success != total:
        exit(1)
