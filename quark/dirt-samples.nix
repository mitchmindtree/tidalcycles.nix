{
  lib,
  stdenv,
  fetchFromGitHub,
  mkQuark,
  dirt-samples-src ? null,
}:
mkQuark rec {
  inherit lib stdenv;
  name = "Dirt-Samples";
  src =
    if dirt-samples-src != null
    then dirt-samples-src
    else
      fetchFromGitHub {
        owner = "tidalcycles";
        repo = name;
        rev = "master";
        sha256 = "sha256-h8vQxRym6QzNLOTZU7A43VCHuG0H77l+BFwXnC0L1CE=";
      };
}
