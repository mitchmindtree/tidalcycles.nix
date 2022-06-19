{
  description = "A Tidal Cycles project. https://tidalcycles.org/";

  inputs.tidal.url = "github:mitchmindtree/tidalcycles.nix";

  outputs = inputs:
    inputs.tidal.utils.eachSupportedSystem (system: {
      devShells = inputs.tidal.devShells.${system};
      formatter = inputs.tidal.formatter.${system};
    });
}
