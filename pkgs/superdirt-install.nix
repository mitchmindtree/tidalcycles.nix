# Installs SuperDirt under your user's supercollider quarks.
{
  supercolliderQuarks,
  supercollider-with-sc3-plugins,
  writeShellScriptBin,
}:
writeShellScriptBin "superdirt-install" ''
  ${supercollider-with-sc3-plugins}/bin/sclang ${supercolliderQuarks.superdirt}/install.scd
''
