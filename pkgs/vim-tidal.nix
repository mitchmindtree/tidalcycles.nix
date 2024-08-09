{
  ghcWithTidal,
  lib,
  sclang-with-superdirt,
  src,
  superdirt-start-sc,
  tidal-src,
  vimUtils,
  writeText,
}:
vimUtils.buildVimPluginFrom2Nix {
  inherit src;
  pname = "vim-tidal";
  version = "master";
  postInstall = let
    # A vimscript file to set Nix defaults for ghci and `BootTidal.hs`.
    defaults-file = writeText "vim-tidal-defaults.vim" ''
      " Prepend defaults provided by Nix packages.
      if !exists("g:tidal_ghci")
        let g:tidal_ghci = "${ghcWithTidal}/bin/ghci"
      endif
      if !exists("g:tidal_sclang")
        let g:tidal_sclang = "${sclang-with-superdirt}/bin/sclang-with-superdirt"
      endif
      if !exists("g:tidal_boot_fallback")
        let g:tidal_boot_fallback = "${tidal-src}/BootTidal.hs"
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
    homepage = "https://github.com/tidalcycles/vim-tidal";
    license = lib.licenses.mit;
  };
}
