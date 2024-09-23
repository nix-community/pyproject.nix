{ lib, resolvers }:
let
  inherit (resolvers) resolveCyclic resolveNonCyclic;
  inherit (lib) makeScope;

  mkPkgs' = import ./pkgs { inherit lib; };

  # Build-system package names to memoise
  memoNames = lib.attrNames (mkPkgs' {
    # Hack: We only need attrNames
    pyprojectBootstrapHook = null;
    callPackage = null;
  });

  mkResolveBuildSystem =
    set:
    let
      resolveNonCyclic' = resolveNonCyclic memoNames set;
    in
    spec:
    map (name: set.${name}) (
      resolveNonCyclic' (
        if spec != { } then
          spec
        else
          {
            # Implement fallback behaviour in case of empty build-system
            setuptools = [ ];
            wheel = [ ];
          }
      )
    );

  mkResolveVirtualEnv = set: spec: map (name: set.${name}) (resolveCyclic set spec);

  pkgsFun = final: mkPkgs' { inherit (final) callPackage pyprojectBootstrapHook; };

in

{
  python,
  newScope,
  buildPackages,
  stdenv,
}:
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

          # Make a virtual env from resolved dependencies
          mkVirtualEnv =
            name: spec:
            pkgsFinal.stdenv.mkDerivation {
              inherit name;

              dontConfigure = true;
              dontUnpack = true;
              dontBuild = true;

              nativeBuildInputs = [
                pkgsFinal.pyprojectMakeVenvHook
              ];

              buildInputs = pkgsFinal.resolveVirtualEnv spec;
            };

          hooks = pkgsFinal.callPackage ./hooks { };
          inherit (pkgsFinal.hooks)
            pyprojectConfigureHook
            pyprojectBuildHook
            pyprojectInstallHook
            pyprojectBytecodeHook
            pyprojectOutputSetupHook
            pyprojectMakeVenvHook
            pyprojectHook
            pyprojectWheelHook
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
