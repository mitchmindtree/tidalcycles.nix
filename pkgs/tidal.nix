# Run the tidal interpreter (ghci running BootTidal.hs).
{
  ghcWithTidal,
  src,
  writeShellScriptBin,
}:
writeShellScriptBin "tidal" ''
  ${ghcWithTidal}/bin/ghci -ghci-script ${src}/BootTidal.hs
''
