from typing import Any


def pytest_configure(config: Any) -> None:
    plugin = config.pluginmanager.getplugin("mypy")
    plugin.mypy_argv.append("--strict")
