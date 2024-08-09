{
  description = ''
    A Nix flake for working with Tidal Cycles. https://tidalcycles.org/
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Non-flake source.
    dirt-samples-src = {
      url = "github:tidalcycles/dirt-samples";
      flake = false;
    };
    superdirt-src = {
      url = "github:musikinformatik/superdirt";
      flake = false;
    };
    tidal-src = {
      url = "github:tidalcycles/tidal/v1.9.5";
      flake = false;
    };
    vim-tidal-src = {
      url = "github:tidalcycles/vim-tidal";
      flake = false;
    };
    vowel-src = {
      url = "github:supercollider-quarks/vowel";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      # TODO: We should support darwin (macOS) here, supercollider package
      # currently lacks support.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];

      overlays = [ inputs.self.overlays.default ];

      perSystemPkgs =
        f:
        inputs.nixpkgs.lib.genAttrs systems (
          system: f (import inputs.nixpkgs { inherit overlays system; })
        );
    in
    {
      overlays = {
        tidal = import ./overlay.nix {
          inherit (inputs)
            dirt-samples-src
            superdirt-src
            tidal-src
            vim-tidal-src
            vowel-src
            ;
        };
        default = inputs.self.overlays.tidal;
      };

      packages = perSystemPkgs (pkgs: {
        ghcWithTidal = pkgs.ghcWithTidal;
        supercollider = pkgs.supercollider-with-sc3-plugins;
        sclang-with-superdirt = pkgs.sclang-with-superdirt;
        superdirt-start-sc = pkgs.superdirt-start-sc;
        superdirt-start = pkgs.superdirt-start;
        superdirt-install = pkgs.superdirt-install;
        tidal = pkgs.tidal;
        vim-tidal = pkgs.vimPlugins.vim-tidal;
        default = inputs.self.packages.${pkgs.system}.tidal;
      });

      devShells = perSystemPkgs (pkgs: {
        tidal = pkgs.callPackage ./shell.nix { };
        default = inputs.self.devShells.${pkgs.system}.tidal;
      });

      templates = {
        tidal-project = {
          path = ./template;
          description = ''
            A standard nix flake template for a Tidal Cycles project.
          '';
        };
        default = inputs.self.templates.tidal-project;
      };

      formatter = perSystemPkgs (pkgs: pkgs.nixfmt-rfc-style);
    };
}
