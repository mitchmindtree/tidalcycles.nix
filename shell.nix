{
  mkShell,
  sclang-with-superdirt,
  supercollider-with-sc3-plugins,
  supercolliderQuarks,
  superdirt-start,
  superdirt-install,
  tidal,
}:
mkShell {
  name = "tidal";
  buildInputs = [
    sclang-with-superdirt
    supercollider-with-sc3-plugins
    superdirt-start
    superdirt-install
    tidal
  ];
  # Convenient access to a config providing all quarks required for Tidal.
  SUPERDIRT_SCLANG_CONF = "${supercolliderQuarks.superdirt}/sclang_conf.yaml";
}
