# A sclang command with superdirt included via conf yaml.
{
  supercollider-with-sc3-plugins,
  supercolliderQuarks,
  writeShellApplication,
}:
let
  supercollider = supercollider-with-sc3-plugins;
  superdirt = supercolliderQuarks.superdirt;
in
writeShellApplication {
  name = "sclang-with-superdirt";
  runtimeInputs = [ supercollider-with-sc3-plugins ];
  text = ''
    ${supercollider}/bin/sclang -l "${superdirt}/sclang_conf.yaml" "$@"
  '';
}
