{
  description = ''
    A Nix flake for working with Tidal Cycles. https://tidalcycles.org/
  '';

  inputs = {
    dirt-samples-src = {
      url = "github:tidalcycles/dirt-samples/master";
      flake = false;
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    superdirt-src = {
      url = "github:musikinformatik/superdirt/master"; # use `develop` branch as its default?
      flake = false;
    };
    tidal-src = {
      url = "github:tidalcycles/tidal/main";
      flake = false;
    };
    vim-tidal-src = {
      url = "github:tidalcycles/vim-tidal/master";
      flake = false;
    };
    vowel-src = {
      url = "github:supercollider-quarks/vowel/master";
      flake = false;
    };
  };

  outputs = inputs: let
    out = system: let
      env = import ./env { inherit inputs; inherit system; };
      quark-lib = import ./quark/lib.nix;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      ghcWithTidal = pkgs.haskellPackages.ghcWithPackages (p: [ p.tidal ]);
    in rec {
      packages.${system} = rec {
        # SuperCollider quarks that are necessary for Tidal.
        dirt-samples = pkgs.callPackage ./quark/dirt-samples.nix {
          inherit (quark-lib) mkQuark;
          inherit (inputs) dirt-samples-src;
        };
        vowel = pkgs.callPackage ./quark/vowel.nix {
          inherit (quark-lib) mkQuark;
          inherit (inputs) vowel-src;
        };
        superdirt = pkgs.callPackage ./quark/superdirt.nix {
          inherit (quark-lib) mkQuark;
          inherit (inputs) superdirt-src;
          dependencies = [ dirt-samples vowel ];
        };

        # Run `SuperDirt.start` in supercollider, ready for tidal.
        superdirt-start = pkgs.writeShellScriptBin "superdirt-start" ''
          ${pkgs.supercollider-with-plugins}/bin/sclang \
            -l "${superdirt}/sclang_conf.yaml" \
            ${pkgs.writeText "superdirt-start.sc" "SuperDirt.start;"}
        '';

        # Installs SuperDirt under your user's supercollider quarks.
        superdirt-install = pkgs.writeShellScriptBin "superdirt-start" ''
          ${pkgs.supercollider-with-plugins}/bin/sclang ${superdirt}/install.sc
        '';

        # Run the tidal interpreter (ghci running BootTidal.hs).
        tidal = pkgs.writeShellScriptBin "tidal" ''
          ${ghcWithTidal}/bin/ghci -ghci-script ${inputs.tidal-src}/BootTidal.hs
        '';

        # Vim plugin for tidalcycles.
        vim-tidal = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "vim-tidal";
          version = "master";
          src = inputs.vim-tidal-src;
          meta = {
            homepage = "https://github.com/tidalcycles/vim-tidal.vim";
            license = pkgs.lib.licenses.mit;
          };
        };
      };

      devShells.${system} = rec {
        # A shell that provides a set of commonly useful packages for tidal.
        tidal = pkgs.mkShell {
          name = "tidal";
          buildInputs = [
            pkgs.supercollider-with-plugins
            packages.${system}.superdirt-start
            packages.${system}.tidal
          ];
        };
        default = tidal;
      };
    };
  in
    out "x86_64-linux";
}
