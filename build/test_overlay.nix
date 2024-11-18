{
  lib,
  pyproject-nix,
}:
let
  overlay' =
    final: _prev:
    lib.mapAttrs
      (
        name: pkg:
        if pyproject-nix.build.lib.isBootstrapPackage name then
          final.callPackage pkg { pyprojectHook = final.pyprojectBootstrapHook; }
        else
          final.callPackage pkg { }
      )
      {
        flit-core = ./pkgs/flit-core;
        packaging = ./pkgs/packaging;
        pyproject-hooks = ./pkgs/pyproject-hooks;
        setuptools = ./pkgs/setuptools;
        wheel = ./pkgs/wheel;
        hatchling = ./pkgs/hatchling;
        pdm-backend = ./pkgs/pdm-backend;
        cython = ./pkgs/cython;
        meson = ./pkgs/meson;
        build = ./pkgs/build;
        installer = ./pkgs/installer;
        pathspec = ./pkgs/pathspec;
        pluggy = ./pkgs/pluggy;
        setuptools-scm = ./pkgs/setuptools-scm;
        trove-classifiers = ./pkgs/trove-classifiers;
        calver = ./pkgs/calver;
        zipp = ./pkgs/zipp;
        tomli-w = ./pkgs/tomli-w;
        cffi = ./pkgs/cffi;
        maturin = ./pkgs/maturin;
        setuptools-rust = ./pkgs/setuptools-rust;
        pycparser = ./pkgs/pycparser;
        typing-extensions = ./pkgs/typing-extensions;
        semantic-version = ./pkgs/semantic-version;
        tomli = ./pkgs/tomli;
        pip = ./pkgs/pip;
      };

  crossOverlay = lib.composeExtensions (_final: prev: {
    pythonPkgsBuildHost = prev.pythonPkgsBuildHost.overrideScope overlay';
  }) overlay';

in
final: prev:
if prev.stdenv.buildPlatform != prev.stdenv.hostPlatform then
  crossOverlay final prev
else
  overlay' final prev
