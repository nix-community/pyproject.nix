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

  mkPythonSet =
    {
      python,
      stdenv,
      pythonPkgsBuildHost,
      bootstrapHooks,
      pythonPkgsFun,
      pkgsFinal,
    }:
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
    // pythonPkgsFun pkgsFinal;

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
    bootstrapHooks = final.callPackage ./hooks {
      python = final.python.pythonOnBuildForHost;
      resolveBuildSystem = mkResolveBuildSystem final.pythonPkgsBootstrap;
      hooks = bootstrapHooks;
    };

  in
  (mkPythonSet {
    inherit stdenv;
    pkgsFinal = final;
    python = python.pythonOnBuildForHost;
    pythonPkgsBuildHost = final.pythonPkgsHostHost;
    bootstrapHooks = final.pythonPkgsBootstrap.hooks;
    pythonPkgsFun = pkgsFun;
  })
  // {
    # Bootstrap packages used to bootstrap set
    pythonPkgsBootstrap = makeScope buildPackages.newScope (
      pkgsFinal:
      mkPythonSet {
        inherit (buildPackages) stdenv;
        inherit bootstrapHooks pkgsFinal;
        python = python.pythonOnBuildForHost;
        pythonPkgsBuildHost = final.pythonPkgsBootstrap;
        pythonPkgsFun =
          _:
          final.callPackage ./bootstrap.nix {
            inherit (bootstrapHooks) pyprojectInstallHook pyprojectBytecodeHook pyprojectOutputSetupHook;
            python = final.python.pythonOnBuildForHost;
          };
      }
    );

    # Python packages for the build host.
    # In case of cross compilation this set is instantiated with host packages, otherwise
    # it's aliasing pythonPkgsHostHost
    pythonPkgsBuildHost =
      if stdenv.buildPlatform != stdenv.hostPlatform then
        (makeScope buildPackages.newScope (
          pkgsFinal:
          mkPythonSet {
            inherit (buildPackages) stdenv;
            python = python.pythonOnBuildForHost;
            inherit (final) pythonPkgsBuildHost;
            bootstrapHooks = final.pythonPkgsBootstrap.hooks;
            pythonPkgsFun = pkgsFun;
            inherit pkgsFinal;
          }
        ))
      else
        final;

    # Alias the host packages (this set) set as pythonPkgsHostHost
    pythonPkgsHostHost = final;
  }
)
