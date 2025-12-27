# :snowflake: devflake :snowflake:

Opinionated flake for development of various things I work on using multiple languages/frameworks/tools. Uses `flake-parts`, `numtide/devshell`, `direnv` and `nix-direnv`. The motivation for this is to create an environment which is easy to use and hooks well with editors (particularly VSCode).

## Workflow

This flake is intended to fit with my workflow, which is with [Visual Studio Code](https://code.visualstudio.com), NixOS and direnv. This project is not intended to be a replacement or alternative to excellent projects such as direnv, devenv, devshell, lorri etc. The flake setups up a reproducible development environment for different programming contexts, and aims to be as declarative as possible whilst allowing some flexibility. 


## Features

- Based off `direnv`, nix flakes and `devshell` for portable, easy, reproducible development environments.
- Editor integration, with first-class support for Visual Studio Code/VSCodium (extensions permitting).
- Configurable and extensible language support via the module system:
  - Languages which allow any number of includes/extra packages are automatically added with the creation of a file!
  - `C/C++` GCC or Clang/LLVM C/C++ development environment with options for alternate build systems.
  - `Python` with pre-installed packages intended for scientific work and visualisation.
  - `Node/JS/TS` with options for TypeScript, and package managers like npm, pnpm, yarn.
  - Reproducible LaTeX environment with support for LTeX+.
  - Easy modification of development environments for each language.
<!-- - Setting up local `settings.json` for VSCode (WIP). -->
## Usage

To minimise clutter with projects, the majority of configuration is done inside the `nix` folder, with the `flake.nix` (and corresponding lockfile) left in the root of the directory. This section of the README can be considered to be the "Documentation".

0. Have `direnv` installed and that it is hooked into your shell. Have flakes enabled via some mechanism with the flag `experimental-features = nix-command flakes` e.g. in `nix.conf`.
1. Either click `Use this template` on GitHub and follow the instructions, or in a new repository, run `nix flake init -t github:chpxu/development-flake#default`.
2. In `flake.nix`, inside the `outputs` function, define your available programming languages, e.g.
  ```nix
    outputs = {...} @ inputs {
      # ... other stuff you can ignore
      python = {
        enable = true;
      };
      tex = {
        enable = true;
        ltex.enable = true;
      };
    }
  ```
3. Depending on what you have enabled, you can now switch to an isolated sandbox for those languages!
  - If you enabled `python`: `nix develop .#python`
  - See `nix/languages/*/default.nix` to see the available configuration options.

### Why you might not want to use devflake

1. It is _very_ nix-ified and if you haven't figured out a way to make your environment more nix-independent (e.g. using `uv` for Python, which this flake supports) then it may well not be worth your time.
2. It is an opinionated abstraction layer ontop of `numtide/devshell` and `flake-parts`, and you may find that you need more of their featureset than what I provide.
3. Unstable: this version has come fresh out of the refactor oven. I hope to not make (too many?) any breaking changes afterwards

## Extending devflake

Currently, devflake supports C, C++, Fortran, JS/TS, LaTeX, Python and Nix. You may use other languages than these, use packages that aren't available in nixpkgs or otherwise. Including these should be easy enough.

### Including other languages

First of all, thanks and I would really appreciate it if you opened a PR with this language!

1. Inside `nix/languages` folder, create a folder for your language with a `default.nix` file.
2. Inside `default.nix`, mirror the other files. A basic example could be
```nix
  # nix/languages/foo/default.nix
  {
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.foo;
  t = lib.types;
in
{
  options.foo = {
    enable = lib.mkOption {
      type = t.bool;
      default = false;
      description = "Enable foo in the environment.";
    };
    version = lib.mkOption {
      type = t.enum [
        "310"
        "311"
        "312"
        "313"
        "314"
        "315"
      ]; # Currently supported by NixOS 26.05
      default = "312";
      description = "The foo version to use in the project, e.g \"310\" corresponds to foo 3.10.";
    };
  };
  config = lib.mkIf cfg.enable {
    perSystem = {pkgs, ...}: {
      devshells.foo = {...}@args: {
        devshell = {
          name = "foo";
        };
        packages = [ ];
        env = [ {
          name = "DUMMY_ENV_VAR"; value = "DUMMY VALUE";
        }]
      };
    } 
  };
}
```
3. Add this file to `imports` inside `flake.nix`. (TODO: make this automatic). This then exposes `foo` as an option to configure.

### Non nixpkgs software

You should follow the instructions to construct a package for your software, e.g. use `pkgs.python3.pkgs.buildPythonPackage`, or `stdenv.mkDerivation`. You should then add your package into the respective language's `packages` attribute (or inside the `python3.withPackages` call for Python).
<!-- The `nix` folder structure looks something like this:
```
.
└── nix/
    ├── default.nix
    ├── languages/
    │   ├── c/
    │   │   ├── c.nix
    │   │   └── # other c/c++ configuration files
    │   ├── python/
    │   │   ├── python.nix
    │   │   └── # other python configuration files
    │   ├── js/
    │   │   ├── js.nix
    │   │   └── # other js configuration files
    │   └── #  other languages
    ├── overlays/
    │   └── default.nix
    └── misc/
        ├── write_vscode_settings.nix
        ├── helper.nix
        └── # other files
```

- `default.nix` is the file which imports and includes everything from all the other files and sets up package configuration, shellHook, vscode configuration etc. This file is then included inside `flake.nix` to be consumed by `devShells`.
- `packages/<language>` folders contain nix files that detail the relevant packages to be installed.
- `overlays` folder contains, well, any overlays you might want to use. 
  - For example, configuring python311 to `enableOptimisations` and disable `reproducibleBuild` for potential speedups
- `misc` folder contains any general functions written to be used across the project (`helper.nix`), and any configuration that does not directly impact the shell itself (e.g. editor settings). -->

## Editor/IDE Integration

Currently this is WIP, and my main goal is making sure this flake works well with VSCode.

### Visual Studio Code

1. Have the [direnv extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) installed (either globally or in your workspace). Ensure you trust your workspace so it can execute shell scripts. 

The repository contains a file `misc/write_vscode_settings.nix` which converts sets of Nix expressions to a JSON string, and then writes to `.vscode/settings.json` in the directory where the flake is located. The file created *is* editable which means you can mess around with settings after the original file is created, however the file is not prettified and you may want external tools like `jq` or an extension like `Prettier` to auto-format it back to a readable state.

TODO: this is currently under refactor.

### (Neo)Vim (untested)

1. Install [vim-direnv](https://github.com/direnv/direnv.vim) with your plugin manager.

Launching vim from the directory of the project, after direnv has loaded, should hopefully make it pick up the right environment variables. Open an issue if it doesn't work.
### Emacs (untested)

1. Install [emacs-direnv](https://github.com/wbolster/emacs-direnv).

Launching emacs from the directory of the project, after direnv has loaded, should hopefully make it pick up the right environment variables.

## Contributing

Thanks for viewing this repo!

I don't really use anything other than NixOS and VSCode. I don't do development on Windows anymore. Extending the flake to cope with some other editors or platforms would be greatly appreciated and would help a bunch of others if they ever happen to come across this.

## Other niceties

- [zsh](https://www.zsh.org/) and [starship](https://starship.rs/).

## Credits and inspiration :rocket:

- [fufexan's C/C++ config](https://gist.github.com/fufexan/2e7020d05ff940c255d74d5c5e712815) which got me started on using these languages in nix years ago
- [Vortriz/scientific-env](https://github.com/Vortriz/scientific-env/) which gave me a concrete example of how to use `flake-parts` and `numtide/devshell`, as well as for statix, deadnix and treefmt-nix.
- [vic/import-tree](https://github.com/vic/import-tree) for making importing very powerful and easy
- [flake-parts](https://github.com/hercules-ci/flake-parts) for an absolutely amazing multi-flake library
- [flake-utils](https://github.com/numtide/flake-utils) for getting me started on this journey
- [numtide/devshell](https://github.com/numtide/devshell) for simplifying the creation of numerous devShells!
- [oppiliappan/statix](https://github.com/oppiliappan/statix)
- [astro/deadnix](https://github.com/astro/deadnix)
- [treefmt-nix](https://github.com/numtide/treefmt-nix/)