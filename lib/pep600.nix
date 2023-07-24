_:
{
  /* Normalize legacy (pre PEP-600) platform tags to compatible ones.

     Type: normalizeTag :: string -> string

     Example:
     # normalizeTag "manylinux1_x86_64"
     "manylinux_2_5_x86_64"
  */
  normalizeTag =
    let
      # Map legacy (pre PEP-600) aliases to PEP-600 compliant ones
      #
      # https://peps.python.org/pep-0600/#legacy-manylinux-tags
      legacyManyLinuxTags = {
        manylinux1_x86_64 = "manylinux_2_5_x86_64";
        manylinux1_i686 = "manylinux_2_5_i686";
        manylinux2010_x86_64 = "manylinux_2_12_x86_64";
        manylinux2010_i686 = "manylinux_2_12_i686";
        manylinux2014_x86_64 = "manylinux_2_17_x86_64";
        manylinux2014_i686 = "manylinux_2_17_i686";
        manylinux2014_aarch64 = "manylinux_2_17_aarch64";
        manylinux2014_armv7l = "manylinux_2_17_armv7l";
        manylinux2014_ppc64 = "manylinux_2_17_ppc64";
        manylinux2014_ppc64le = "manylinux_2_17_ppc64le";
        manylinux2014_s390x = "manylinux_2_17_s390x";
      };
    in
    tag: legacyManyLinuxTags.${tag} or tag;
}
