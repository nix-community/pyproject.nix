{ pep600, ... }:
let
  inherit (pep600) legacyAliases manyLinuxTagCompatible;

  mockStdenvs =
    let
      mkMock = pname: version: cpuName: {
        cc = {
          libc = {
            inherit pname version;
          };
        };
        targetPlatform.parsed.cpu.name = cpuName;
      };
    in
    {
      x86_64-linux = {
        glibc_2_4 = mkMock "glibc" "2.4" "x86_64";
        glibc_2_5 = mkMock "glibc" "2.5" "x86_64";
        musl_1_2_3 = mkMock "musl" "1.2.3" "x86_64";
      };
    };

in
{
  legacyAliases = {
    testSimple = {
      expr = legacyAliases."manylinux1_x86_64" or "manylinux1_x86_64";
      expected = "manylinux_2_5_x86_64";
    };

    testNoMatch = {
      expr = legacyAliases."nomanylinux1_x86_64" or "nomanylinux1_x86_64";
      expected = "nomanylinux1_x86_64";
    };
  };

  manyLinuxTagCompatible = {
    testSimpleIncompatible = {
      expr = manyLinuxTagCompatible mockStdenvs.x86_64-linux.glibc_2_4 "manylinux1_x86_64";
      expected = false;
    };

    testMusl = {
      expr = manyLinuxTagCompatible mockStdenvs.x86_64-linux.musl_1_2_3 "manylinux1_x86_64";
      expected = false;
    };

    testSimpleCompatible = {
      expr = manyLinuxTagCompatible mockStdenvs.x86_64-linux.glibc_2_5 "manylinux1_x86_64";
      expected = true;
    };

    testSimpleArchIncompatible = {
      expr = manyLinuxTagCompatible mockStdenvs.x86_64-linux.glibc_2_5 "manylinux2014_armv7l";
      expected = false;
    };
  };
}
