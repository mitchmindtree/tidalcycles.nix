{
  description = ''
    A Nix flake for working with Tidal Cycles. https://tidalcycles.org/
  '';

  inputs = {
    dirt-samples-src = {
      url = "github:tidalcycles/dirt-samples/master";
      flake = false;
    };
    utils = {
      url = "github:numtide/flake-utils";
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
      # TODO: Switch back to `tidalcycles` repo once Vim8 terminal support
      # lands and following boot tidal and superdirt terminal commits.
      # See this PR: https://github.com/tidalcycles/vim-tidal/pull/74
      # url = "github:tidalcycles/vim-tidal/master";
      url = "github:mitchmindtree/vim-tidal/find-sc-boot";
      flake = false;
    };
    vowel-src = {
      url = "github:supercollider-quarks/vowel/master";
      flake = false;
    };
  };

  outputs = inputs: let
    # TODO: We should support darwin (macOS) here, supercollider package
    # currently lacks support.
    utils.supportedSystems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];
    utils.eachSupportedSystem =
      inputs.utils.lib.eachSystem utils.supportedSystems;

    mkPackages = pkgs: let
      quarklib = pkgs.callPackage ./quark/lib.nix {};
      ghcWithTidal = pkgs.haskellPackages.ghcWithPackages (p: [p.tidal]);
    in rec {
      # SuperCollider quarks that are necessary for Tidal.
      dirt-samples = quarklib.mkQuark {
        name = "Dirt-Samples";
        src = inputs.dirt-samples-src;
      };
      vowel = quarklib.mkQuark {
        name = "Vowel";
        src = inputs.vowel-src;
      };
      superdirt = quarklib.mkQuark {
        name = "SuperDirt";
        src = inputs.superdirt-src;
        dependencies = [dirt-samples vowel];
      };

      # Supercollider with the SC3 plugins used by tidal.
      supercollider = pkgs.supercollider-with-plugins.override {
        plugins = [pkgs.supercolliderPlugins.sc3-plugins];
      };

      # A sclang command with superdirt included via conf yaml.
      sclang-with-superdirt = pkgs.writeShellApplication {
        name = "sclang-with-superdirt";
        runtimeInputs = [supercollider];
        text = ''
          ${supercollider}/bin/sclang -l "${superdirt}/sclang_conf.yaml" "$@"
        '';
      };

      # A very simple default superdirt start file.
      superdirt-start-sc = pkgs.writeText "superdirt-start.sc" "SuperDirt.start;";

      # Run `SuperDirt.start` in supercollider, ready for tidal.
      superdirt-start = pkgs.writeShellApplication {
        name = "superdirt-start";
        runtimeInputs = [supercollider];
        text = ''
          ${sclang-with-superdirt}/bin/sclang-with-superdirt ${superdirt-start-sc}
        '';
      };

      # Installs SuperDirt under your user's supercollider quarks.
      superdirt-install = pkgs.writeShellScriptBin "superdirt-start" ''
        ${supercollider}/bin/sclang ${superdirt}/install.sc
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
        postInstall = let
          # A vimscript file to set Nix defaults for ghci and `BootTidal.hs`.
          defaults-file = pkgs.writeText "vim-tidal-defaults.vim" ''
            " Prepend defaults provided by Nix packages.
            if !exists("g:tidal_ghci")
              let g:tidal_ghci = "${ghcWithTidal}/bin/ghci"
            endif
            if !exists("g:tidal_sclang")
              let g:tidal_sclang = "${sclang-with-superdirt}/bin/sclang-with-superdirt"
            endif
            if !exists("g:tidal_boot_fallback")
              let g:tidal_boot_fallback = "${inputs.tidal-src}/BootTidal.hs"
            endif
            if !exists("g:tidal_sc_boot_fallback")
              let g:tidal_sc_boot_fallback = "${superdirt-start-sc}"
            endif
          '';
        in ''
          # Prepend a line to `plugin/tidal.vim` to source the defaults.
          mv $out/plugin/tidal.vim $out/plugin/tidal.vim.old
          cat ${defaults-file} $out/plugin/tidal.vim.old > $out/plugin/tidal.vim
          rm $out/plugin/tidal.vim.old

          # Remove unnecessary files.
          rm -r $out/bin
          rm $out/Makefile
          rm $out/Tidal.ghci
        '';
        meta = {
          homepage = "https://github.com/tidalcycles/vim-tidal.vim";
          license = pkgs.lib.licenses.mit;
        };
      };
    };

    overlays = rec {
      tidal = final: prev: let
        tidalpkgs = mkPackages prev;
      in {
        inherit (tidalpkgs) superdirt-start superdirt-install tidal;
        vimPlugins = prev.vimPlugins // {inherit (tidalpkgs) vim-tidal;};
      };
      default = tidal;
    };

    mkDevShells = pkgs: tidalpkgs: rec {
      # A shell that provides a set of commonly useful packages for tidal.
      tidal = pkgs.mkShell {
        name = "tidal";
        buildInputs = [
          tidalpkgs.supercollider
          tidalpkgs.superdirt-start
          tidalpkgs.tidal
        ];
        # Convenient access to a config providing all quarks required for Tidal.
        SUPERDIRT_SCLANG_CONF = "${tidalpkgs.superdirt}/sclang_conf.yaml";
      };
      default = tidal;
    };

    templates = rec {
      tidal-project = {
        path = ./template;
        description = ''
          A standard nix flake template for a Tidal Cycles project.
        '';
      };
      default = tidal-project;
    };

    mkOutput = system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in rec {
      packages = mkPackages pkgs;
      devShells = mkDevShells pkgs packages;
      formatter = pkgs.alejandra;
    };

    # The output for each system.
    systemOutputs = utils.eachSupportedSystem mkOutput;
  in
    # Merge the outputs and overlays.
    systemOutputs // {inherit overlays templates utils;};
}
