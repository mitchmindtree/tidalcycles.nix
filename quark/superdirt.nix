{
  lib,
  stdenv,
  fetchFromGitHub,
  mkQuark,
  superdirt-src ? null,
  dependencies ? [],
}:
mkQuark rec {
  inherit dependencies lib stdenv;
  name = "SuperDirt";
  src =
    if superdirt-src != null
    then superdirt-src
    else
      fetchFromGitHub {
        owner = "musikinformatik";
        repo = name;
        rev = "master";
        sha256 = "sha256-FFBJBlUY6jttEEkn3qldS8z2qoncSyDITUy+x/6l5F8=";
      };
}
