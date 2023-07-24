_:

{
  # Maps Nixpkgs CPU values to target machines known to be supported for manylinux* wheels.
  # (a.k.a. `uname -m` output from CentOS 7)
  #
  # s390x is not supported in Nixpkgs, so we don't map it.
  manyLinuxTargetMachines = {
    x86_64 = "x86_64";
    i686 = "i686";
    aarch64 = "aarch64";
    armv7l = "armv7l";
    powerpc64 = "ppc64";
    powerpc64le = "ppc64le";
  };
}
