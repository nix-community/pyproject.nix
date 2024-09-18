#!/usr/bin/env python3
from venv import EnvBuilder
from pathlib import Path
import os.path
import shutil
import stat
import sys
import os


EXECUTABLE = os.path.basename(sys.executable)
PYTHON_VERSION = ".".join((str(sys.version_info.major), str(sys.version_info.minor)))
SITE_PACKAGES = os.path.join("lib", f"python{PYTHON_VERSION}", "site-packages")


# Look for shebangs pointing to Python bin directory, rewrite them to venv directory
dep_shebang = ("#!" + os.path.dirname(sys.executable)).encode()


# Special rules for bin directory:
# - Copy symlinks
# - Rewrite scripts for shebangs
# - Symlink anything else
def write_bin_dir(bin_dir: Path, bin_out: Path) -> None:
    out_shebang: bytes = f"#!{bin_out}".encode()

    for bin in os.listdir(bin_dir):
        bin_file = bin_dir.joinpath(bin)
        bin_file_out = bin_out.joinpath(bin_file.name)
        st_mode = bin_file.lstat().st_mode

        # Copy symlinks
        if stat.S_ISLNK(st_mode):
            shutil.copy(bin_file, bin_out.joinpath(bin_file.name), follow_symlinks=False)

        # Rewrite script shebangs
        elif stat.S_ISREG(st_mode):
            # Check if file starts with Python shebang
            with open(bin_file, "rb") as f_in:
                shebang = f_in.read(len(dep_shebang))
                # If it does, rewrite it to venv interpreter
                if shebang == dep_shebang:
                    with open(bin_file_out, "wb") as f_out:
                        f_out.write(out_shebang)
                        shutil.copyfileobj(f_in, f_out)
                    os.chmod(bin_file_out, st_mode) # Copy mode
                    continue

        # Symlink anything else
        os.symlink(bin_file, bin_file_out)


# Special rules for site-packages:
# - Rewrite package-local symlinks to venv
# - Directly symlink regardless of type
def write_site_packages(site_packages: Path, out_site_packages: Path) -> None:
    for site_pkg_file in os.listdir(site_packages):
        src_file = site_packages.joinpath(site_pkg_file)
        dst_file = out_site_packages.joinpath(site_pkg_file)
        if stat.S_ISLNK(src_file.lstat().st_mode):
            shutil.copy(src_file, dst_file, follow_symlinks=False)
        else:
            os.symlink(src_file, dst_file)


def link_dependency(dep_root: Path, out_root: Path) -> None:
    site_packages = dep_root.joinpath(SITE_PACKAGES)
    bin_dir = dep_root.joinpath("bin")
    nix_support_dir = dep_root.joinpath("nix-support")

    def _link(root: Path, out: Path) -> None:
        # Let other hooks manage the nix-support
        if root == nix_support_dir:
            return

        try:
            os.mkdir(out)
        except FileExistsError:
            pass

        for filename in os.listdir(root):
            path = root.joinpath(filename)

            # Special case handle bin/site-packages
            if path == bin_dir:
                write_bin_dir(path, out.joinpath("bin"))
                continue
            elif path == site_packages:
                write_site_packages(path, out_root.joinpath(SITE_PACKAGES))
                continue

            st_mode = path.lstat().st_mode

            if stat.S_ISLNK(st_mode):
                shutil.copy(path, out.joinpath(path.name))
            elif stat.S_ISREG(st_mode):
                os.symlink(path, out.joinpath(path.name))
            elif stat.S_ISDIR(st_mode):
                _link(path, out.joinpath(path.name))
            else:
                raise ValueError(f"Unhandled st_mode: {st_mode}")

    _link(dep_root, out_root)


def unique_strings(input: list[str]) -> list[str]:
    ret: list[str] = []
    for i in input:
        if i not in ret:
            ret.append(i)
    return ret


def fixup_pyvenv(python_root: Path, out_root: Path) -> None:
    # The venv module writes a command line to pyvenv.cfg using sys.executable
    # This means that the output would contain a reference to build Python
    with open(out_root.joinpath("pyvenv.cfg"), "r") as pyvenv_f:
        pyvenv = pyvenv_f.read()

    pyvenv = pyvenv.replace(os.path.dirname(os.path.dirname(sys.executable)), str(python_root))

    with open(out_root.joinpath("pyvenv.cfg"), "w") as pyvenv_f:
        pyvenv_f.write(pyvenv)


def main():
    import argparse

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("out", help="Virtualenv output directory")
    arg_parser.add_argument("--python", help="Python to link virtualenv to", default=os.path.dirname(os.path.dirname(sys.executable)))
    arg_parser.add_argument("--env", action="append",  help="Source dependencies from environment variable")
    arg_parser.add_argument("--deps", action="append",  help="Source dependencies from colon separated list")

    args = arg_parser.parse_args()

    out_root = Path(args.out)
    python_root = Path(args.python)
    python_executable = python_root.joinpath("bin", EXECUTABLE)

    dependencies: list[Path] = [] # List of dependency roots
    seen_roots: set[str] = set() # Keep track of unique dependency roots

    # Populate dependencies from precisely passed options
    for dep_roots in (args.deps or []):
        for dep_root in dep_roots.split(":"):
            if dep_root in seen_roots:
                continue
            seen_roots.add(dep_root)
            dependencies.append(Path(dep_root))

    # Populate dependencies from env
    for env_var in (args.env or []):
        try:
            env_value = os.environ[env_var]
        except KeyError:
            continue

        for dep_root in env_value.split(":"):
            if dep_root in seen_roots:
                continue
            seen_roots.add(dep_root)
            dependencies.append(Path(dep_root))

    # Write virtualenv
    builder = EnvBuilder(symlinks=True)
    context = builder.ensure_directories(str(out_root))
    context.executable = str(python_executable)
    context.python_dir = str(python_root.joinpath("bin"))
    builder.setup_scripts(context)
    builder.setup_python(context)
    builder.create_configuration(context)
    fixup_pyvenv(python_root, out_root)

    # Link packages into env
    for dep_root in dependencies:
        link_dependency(dep_root, out_root)


if __name__ == "__main__":
    main()
