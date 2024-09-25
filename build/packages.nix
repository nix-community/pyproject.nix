{
  lib,
  pyproject-nix,
  resolvers,
}:
let
  inherit (resolvers) resolveCyclic resolveNonCyclic;
  inherit (lib) makeScope;

  mkPkgs' = import ./pkgs { inherit pyproject-nix lib; };

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
  pkgs,
}:
makeScope newScope (
  final:
  let
    mkPythonSet =
      {
        newScope,
        python,
        stdenv,
        pythonPkgsBuildHost,
        bootstrapHooks,
        pythonPkgsFun,
      }:
      makeScope newScope (
        pkgsFinal:
        {
          inherit python stdenv pythonPkgsBuildHost;

          # Pyproject hook used for bootstrap packages
          pyprojectBootstrapHook = pkgsFinal.pyprojectHook.override {
            inherit (bootstrapHooks) pyprojectConfigureHook pyprojectBuildHook;
          };

          # Initialize dependency resolvers
          resolveBuildSystem = mkResolveBuildSystem pythonPkgsBuildHost;
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
        // pythonPkgsFun pkgsFinal
      );

    bootstrapHooks = final.callPackage ./hooks {
      python = final.python.pythonOnBuildForHost;
      resolveBuildSystem = mkResolveBuildSystem final.pythonPkgsBootstrap;
      hooks = bootstrapHooks;
    };

    isCross = stdenv.buildPlatform != stdenv.hostPlatform;

    # Python packages for the build host
    pythonPkgsBuildHost = mkPythonSet {
      inherit (if isCross then buildPackages else pkgs) stdenv newScope;
      python = python.pythonOnBuildForHost;
      inherit (final) pythonPkgsBuildHost;
      bootstrapHooks = final.pythonPkgsBootstrap.hooks;
      pythonPkgsFun = pkgsFun;
    };

  in
  {
    # Allows overriding Python by calling overrideScope on the outer scope
    inherit python;

    pythonPkgsBootstrap = mkPythonSet {
      inherit (buildPackages) stdenv newScope;
      inherit bootstrapHooks;
      python = python.pythonOnBuildForHost;
      pythonPkgsBuildHost = final.pythonPkgsBootstrap;
      pythonPkgsFun =
        _:
        final.callPackage ./bootstrap.nix {
          inherit (bootstrapHooks) pyprojectInstallHook pyprojectBytecodeHook pyprojectOutputSetupHook;
          python = final.python.pythonOnBuildForHost;
        };
    };

    inherit pythonPkgsBuildHost;

    # Python packages for the target host
    pythonPkgsHostHost =
      # If we're not doing cross reference build host packages
      if isCross then
        mkPythonSet {
          inherit (final) newScope pythonPkgsBuildHost;
          inherit python stdenv;
          bootstrapHooks = final.pythonPkgsBuildHost.hooks;
          pythonPkgsFun = pkgsFun;
        }
      else
        pythonPkgsBuildHost;
  }
)
