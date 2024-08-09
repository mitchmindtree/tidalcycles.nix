# Run `SuperDirt.start` in supercollider, ready for tidal.
{
  sclang-with-superdirt,
  supercollider-with-sc3-plugins,
  superdirt-start-sc,
  writeShellApplication,
}:
writeShellApplication {
  name = "superdirt-start";
  runtimeInputs = [supercollider-with-sc3-plugins];
  text = ''
    start_script="''${1:-${superdirt-start-sc}}"

    if [ "$start_script" == "-h" ] || [ "$start_script" == "--help" ]; then
      echo "Usage: superdirt-start [script]"
      echo
      echo "Start superdirt, optionally running a custom start script."
      echo
      echo "Options:"
      echo "  -h --help    Show this screen."
      exit
    fi

    if [ ! -e "$start_script" ]; then
      echo "The script \"$start_script\" does not exist, aborting."
      exit 1
    fi

    ${sclang-with-superdirt}/bin/sclang-with-superdirt "$start_script"
  '';
}
