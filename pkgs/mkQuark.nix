# Collection of functions to assist with packaging of supercollider quarks.
{ lib, stdenv }:
# A function that, given a Quark source location and its name, creates a
# derivation for the quark installed in an expected location.
#
# The resulting quark contains:
# - `quark` subdirectory, containing the quark itself along with symbolic
# links to each of its dependencies.
# - a `install.scd` file that can be used to install the Quark imperatively.
# - a `sclang_conf.yaml` that can be used to provide the quark and its
# dependencies directly to an interpreter.
#
# TODO: Currently, we assume that the dependency graph is a "tree". The
# reality is that it might be a directed, acyclic graph. We should treat it
# as such and work out if dependencies we require already exist in the link
# tree. Use `lib.lists.listDfs` or `lib.lists.toposort`.
{
  src,
  name,
  dependencies ? [ ],
}:
stdenv.mkDerivation rec {
  inherit name src;
  installPhase =
    let
      # A function for creating links to depenencies in $out/quark.
      ln-dep = dep: ''
        ln -s ${dep}/quark/* $out/quark/
      '';
      ln-deps = lib.concatStrings (map ln-dep dependencies);

      # Write a `sc` file that can be used to install the quark imperatively.
      # TODO: Don't clear all quarks - only remove any with matching ${name}.
      install-scd = ''
        Quarks.clear;
        Quarks.install(\"$out\");
        thisProcess.recompile();
      '';

      # Write a yaml config file with an entry for this quark.
      sclang-conf-yaml = ''
        includePaths:
          - $out/quark
        excludePaths:
            []
        postInlineWarnings: false
        excludeDefaultPaths: false\
      '';
    in
    ''
      mkdir -p $out/quark/${name}
      cp -r ./* $out/quark/${name}
      ${ln-deps}
      echo "${install-scd}" >> $out/install.scd
      echo "${sclang-conf-yaml}" >> $out/sclang_conf.yaml
    '';
}
