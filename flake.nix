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
      # TODO: Switch back to `tidalcycles` repo once Vim8 terminal support lands.
      # See this PR: https://github.com/tidalcycles/vim-tidal/pull/74
      # url = "github:tidalcycles/vim-tidal/master";
      url = "github:mitchmindtree/vim-tidal/flupe-vim8-terminal-rebased";
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
        # Patch the default GHCI with our `tidal` instance.
        # TODO: Update `vim-tidal` to use an env var by default or something instead.
        # Would be much cleaner than a patch with might conflict with future commits.
        patches = [./patch/vim-tidal-ghci.patch];
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
          pkgs.supercollider-with-plugins
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
