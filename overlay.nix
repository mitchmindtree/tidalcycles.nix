{
  dirt-samples-src,
  superdirt-src,
  tidal-src,
  vim-tidal-src,
  vowel-src,
}:
final: prev: {
  # Short-hand for GHC with the tidal pkg.
  ghcWithTidal = prev.haskellPackages.ghcWithPackages (p: [ p.tidal ]);
  # A fn to create a supercollider quark derivation.
  mkQuark = prev.callPackage ./pkgs/mkQuark.nix { };
  # The set of required supercollider quarks.
  supercolliderQuarks = {
    dirt-samples = final.mkQuark {
      name = "Dirt-Samples";
      src = dirt-samples-src;
    };
    vowel = final.mkQuark {
      name = "Vowel";
      src = vowel-src;
    };
    superdirt = final.mkQuark {
      name = "SuperDirt";
      src = superdirt-src;
      dependencies = with final.supercolliderQuarks; [
        dirt-samples
        vowel
      ];
    };
  };
  # A sclang command with superdirt included via conf yaml.
  sclang-with-superdirt = final.callPackage ./pkgs/sclang-with-superdirt.nix { };
  # A very simple default superdirt start file.
  superdirt-start-sc = prev.writeText "superdirt-start.sc" "SuperDirt.start;";
  # Run `SuperDirt.start` in supercollider, ready for tidal.
  superdirt-start = final.callPackage ./pkgs/superdirt-start.nix { };
  # Installs SuperDirt under your user's supercollider quarks.
  superdirt-install = final.callPackage ./pkgs/superdirt-install.nix { };
  # Run the tidal interpreter (ghci running BootTidal.hs).
  tidal = final.callPackage ./pkgs/tidal.nix { src = tidal-src; };
  # The vim tidal plugin tweaked for nix.
  vimPlugins = prev.vimPlugins // {
    vim-tidal = final.callPackage ./pkgs/vim-tidal.nix {
      inherit tidal-src;
      src = vim-tidal-src;
    };
  };
}
