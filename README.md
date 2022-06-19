# tidalcycles.nix

A Nix flake for Tidal Cycles. https://tidalcycles.org/

## Motivation

Typically, setting up a Tidal Cycles environment can be quite involved. It
requires:

- An instance of the Glasgow Haskell Compiler interpreter (GHCi) with the Tidal
  library installed.
- Supercollider, ideally with SC3-plugins included.
- The SuperDirt SuperCollider Quark to be installed (along with its
  dependencies).
- An editor with a Tidal-aware plugin.

This flake aims to provide all of this in a declarative, reproducible manner.

## System Requirements

Requires a recent version of Nix with the "flakes" feature enabled.

## Packages

Includes the following packages:

| Package | Description |
| --- | --- |
| `superdirt-start` | A short-hand command for starting up SuperCollider and running `SuperDirt.start;`. No need to manually install `SuperDirt` as it is provided to `sclang` via a custom `sclang_conf.yaml`. |
| `tidal` | A command for entering the `GHCi` interpreter initialised with [`BootTidal.hs`](https://github.com/tidalcycles/Tidal/blob/main/BootTidal.hs) and the Tidal library loaded. This is a useful repl for experimenting with Tidal. |
| `superdirt-install` | A command for installing SuperDirt and its dependencies under the user's SuperCollider configuration (the traditional installation approach). This is currently the recommended way to provide SuperDirt to the SuperCollider IDE until [this issue](https://github.com/mitchmindtree/tidalcycles.nix/issues/3) is addressed. |
| `vim-tidal` | This is the official [tidalcycles Vim plugin](https://github.com/tidalcycles/vim-tidal) packaged for Nix and patched to use the `tidal` command for its GHCi interpreter. |

## Dev Shell

This flake features a `tidal` devShell. It allows for trivially entering a shell
that includes all of the above packages available on the PATH.

If you have Nix installed with the "flakes" feature enabled, you can enter the
shell with:

```
nix develop github:mitchmindtree/tidalcycles.nix
```

You can then `exit` the shell these tools will no longer be on the `PATH`.

Note that currently the vim plugin still needs to be installed separately. See
the "Overlay" section below and the [Nix Vim wiki](https://nixos.wiki/wiki/Vim)
for more details.

## Tidal Project Template

A flake template for Tidal Cycles projects is provided.

Start a new Tidal Cycles project with the following:

```
nix flake new --template github:mitchmindtree/tidalcycles.nix ./my-tidal-project
```

By default the project will have the `tidal` devShell. `cd` into your project
and run `nix develop` to start working with tidal!

## Overlay

A nixpkgs overlay is provided that allows for "merging" the set of tools
provided by this flake with nixpkgs.

Note that this makes the `vim-tidal` plugin accessible via the `vimPlugins` set
following the nixpkgs convention, e.g. `nixpkgs.vimPlugins.vim-tidal`.

## Editor plugins

Currently this flake and its overlay only provide the `vim-tidal` Vim plugin.

Contributions adding support for other editors/IDE plugins are more than
welcome.

## Contributing

Contributions in the form of PRs are very welcome!

Note that this repository has some automated checks that must pass before a PR
can be merged. This includes a `nix flake check` and standard formatting of the
nix code. To automatically format the nix code before opening a PR, run `nix
fmt` from the root of the repository.

Feel free to post questions, bugs or feature requests as issues.

Please keep in mind that this project is created and maintained in personal
time.
