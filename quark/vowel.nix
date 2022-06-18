{ lib, stdenv, fetchFromGitHub, mkQuark, vowel-src ? null }: mkQuark rec {
  inherit lib stdenv;
  name = "Vowel";
  src = if vowel-src != null then vowel-src else fetchFromGitHub {
    owner = "supercollider-quarks";
    repo = name;
    rev = "master";
    sha256 = "sha256-zfF6cvAGDNYWYsE8dOIo38b+dIymd17Pexg0HiPFbxM=";
  };
}
