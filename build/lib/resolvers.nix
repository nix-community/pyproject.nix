{ lib, ... }:

let
  inherit (lib)
    concatMap
    attrNames
    elemAt
    genericClosure
    match
    genAttrs
    ;

in
{
  /*
    Resolve dependencies using a non-circular supporting approach.

    This implementation is faster than the one supporting circular dependencies, and is memoized.

    `resolveNonCyclic` is intended to resolve build-system dependencies.
  */
  resolveNonCyclic =
    # List of package names to memoize
    memoNames:
    # Package set to resolve packages from
    set:
    let
      recurse' =
        name: extras:
        let
          pkg = set.${name};
          dependencies = pkg.passthru.dependencies or { };
          optional-dependencies = pkg.passthru.optional-dependencies or { };
        in
        [ name ]
        ++ concatMap (name: recurse name dependencies.${name}) (attrNames dependencies)
        ++ concatMap (
          extra:
          let
            extra' = optional-dependencies.${extra};
          in
          concatMap (name: recurse name extra'.${name}) (attrNames extra')
        ) extras;

      # Memoise known build systems with no extras enabled for better performance
      memo = genAttrs memoNames (name: recurse' name [ ]);

      recurse =
        name: extras: if extras == [ ] then (memo.${name} or (recurse' name [ ])) else recurse' name extras;
    in
    # Attribute set of dependencies -> extras { requests = [ "socks" ]; }
    spec: concatMap (name: recurse name spec.${name}) (attrNames spec);

  /*
    Resolve dependencies using a cyclic supporting approach.

    `resolveCyclic` is intended to resolve virtualenv dependencies.
  */
  resolveCyclic =
    # Package set to resolve packages from
    set:
    # Attribute set of dependencies -> extras `{ requests = [ "socks" ]; }`
    spec:
    let
      mkKey = key: { inherit key; };

      # Resolve spec recursively
      closure' = genericClosure {
        startSet = concatMap (
          name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") spec.${name}
        ) (attrNames spec);
        operator =
          { key }:
          let
            m = match "(.+)@(.*)" key;
          in
          # We're looking for a package with extra
          if m != null then
            (
              let
                pkg = set.${elemAt m 0};
                dependencies = pkg.passthru.optional-dependencies.${elemAt m 1};
              in
              concatMap (name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") dependencies.${name}) (
                attrNames dependencies
              )
            )
          # Root package with no extra
          else
            (
              let
                pkg = set.${key};
                dependencies = pkg.passthru.dependencies or { };
              in
              concatMap (name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") dependencies.${name}) (
                attrNames dependencies
              )
            );
      };

      # closure' contains a list like [ { key = "dep@extra"; }]
      # where each dependency containing an extra is a duplicate of it's non-extra enabled
      closure = lib.filter (dep: match ".+@.*" dep.key == null) closure';

    in
    map (dep: dep.key) closure;
}
