{
  description = "A Tidal Cycles project. https://tidalcycles.org/";

  inputs = {
    tidal.url = "github:mitchmindtree/tidalcycles.nix";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    inputs.utils.lib.eachDefaultSystem (system: {
      devShells = inputs.tidal.devShells.${system};
      formatter = inputs.tidal.formatter.${system};
    });
}
