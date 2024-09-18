{
  lib,
  python,
  newScope,
  buildPackages,
  stdenv,
}:

let
  inherit (lib) makeScope;

  resolvers = import ./resolvers.nix { inherit lib; };
  inherit (resolvers) resolveCyclic resolveNonCyclic;

  mkResolveBuildSystem =
    set:
    let
      resolveNonCyclic' = resolveNonCyclic set;
    in
    spec: map (name: set.${name}) (resolveNonCyclic' spec);

  mkResolveVirtualEnv = set: spec: map (name: set.${name}) (resolveCyclic set spec);

  pkgsFun =
    let
      mkPkgs = import ./pkgs { inherit lib; };
    in
    final: mkPkgs { inherit (final) callPackage pyprojectBootstrapHook; };

in
makeScope newScope (
  final:
  let
    mkPythonSet =
      {
        newScope,
        python,
        stdenv,
        pythonPackagesBuildHost,
        bootstrapHooks,
        pythonPackagesFun,
      }:
      makeScope newScope (
        pkgsFinal:
        {
          inherit python stdenv pythonPackagesBuildHost;

          # Pyproject hook used for bootstrap packages
          pyprojectBootstrapHook = pkgsFinal.pyprojectHook.override {
            inherit (bootstrapHooks) pyprojectConfigureHook pyprojectBuildHook;
          };

          # Initialize dependency resolvers
          resolveBuildSystem = mkResolveBuildSystem pythonPackagesBuildHost;
          resolveVirtualEnv = mkResolveVirtualEnv pkgsFinal;

          hooks = pkgsFinal.callPackage ./hooks { };
          inherit (pkgsFinal.hooks)
            pyprojectConfigureHook
            pyprojectBuildHook
            pyprojectInstallHook
            pyprojectBytecodeHook
            pyprojectOutputSetupHook
            pyprojectHook
            ;
        }
        // pythonPackagesFun pkgsFinal
      );

    bootstrapHooks = final.callPackage ./hooks {
      python = final.python.pythonOnBuildForHost;
      resolveBuildSystem = mkResolveBuildSystem final.pythonPackagesBootstrap;
      hooks = bootstrapHooks;
    };

  in
  {
    # Allows overriding Python by calling overrideScope on the outer scope
    inherit python;

    pythonPackagesBootstrap = mkPythonSet {
      inherit (buildPackages) stdenv newScope;
      inherit bootstrapHooks;
      python = python.pythonOnBuildForHost;
      pythonPackagesBuildHost = final.pythonPackagesBootstrap;
      pythonPackagesFun =
        _:
        final.callPackage ./bootstrap.nix {
          inherit (bootstrapHooks) pyprojectInstallHook pyprojectBytecodeHook pyprojectOutputSetupHook;
          python = final.python.pythonOnBuildForHost;
        };
    };

    # Python packages for the build host
    pythonPackagesBuildHost = mkPythonSet {
      inherit (buildPackages) stdenv newScope;
      python = python.pythonOnBuildForHost;
      inherit (final) pythonPackagesBuildHost;
      bootstrapHooks = final.pythonPackagesBootstrap.hooks;
      pythonPackagesFun = pkgsFun;
    };

    # Python packages for the target host
    pythonPackagesHostHost =
      # If we're not doing cross reference build host packages
      if stdenv.buildPlatform != stdenv.hostPlatform then
        mkPythonSet {
          inherit (final) newScope pythonPackagesBuildHost;
          inherit python stdenv;
          bootstrapHooks = final.pythonPackagesBuildHost.hooks;
          pythonPackagesFun = pkgsFun;
        }
      else
        final.pythonPackagesBuildHost;
  }
)
