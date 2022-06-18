# An environment for messing around with Tidal Cycles.
{
  ghcWithTidal,
  stdenv,
  supercollider-with-plugins,
  superdirt,
  superdirt-start,
  tidal-ghci,
}:
stdenv.mkDerivation {
  name = "tidal-dev";
  buildInputs = [
    ghcWithTidal
    supercollider-with-plugins
    superdirt-start
    tidal-ghci
  ];

  # Convenient access to a config providing all quarks required for Tidal.
  SUPERDIRT_SCLANG_CONF = "${superdirt}/sclang_conf.yaml";
}
