# :snowflake: devflake :snowflake:

## **STATUS: UNSTABLE**

Opinionated flake for development of various things I work on using multiple languages/frameworks/tools. Uses `flake-parts`, `numtide/devshell`, `direnv` and `nix-direnv`. The motivation for this is to create an environment which is easy to use, hooks well with editors (particularly VSCode) and is completely self-documented (using Nix).

## Workflow

This flake is intended to fit with my workflow, which is with [Visual Studio Code](https://code.visualstudio.com), NixOS and direnv. This project is not intended to be a replacement or alternative to excellent projects such as direnv, devenv, devshell, lorri etc. The flake setups up a reproducible development environment for different programming contexts, and aims to be as declarative as possible whilst allowing some flexibility. 


## Features

- Based off `direnv`, nix flakes and `devshell` for portable, easy, reproducible development environments.
- Editor integration, with first-class support for Visual Studio Code/VSCodium (extensions permitting).
- Configurable and extensible language support via the module system:
  - Languages which allow any number of includes/extra packages are (semi)-automatically added with the creation of a file!
  - `C/C++` GCC or Clang/LLVM C/C++ development environment with options for build systems, libraries and includes.
  - `Python` with the option to use [uv](https://docs.astral.sh/uv/).
  - `Node/JS/TS` with options for [corepack](https://github.com/nodejs/corepack), [asdf](https://asdf-vm.com/) and package manager configuration for [pnpm](https://pnpm.io/) and [yarn](https://yarnpkg.com).
  - `Fortran` support with `gfortran`, enabling debugger and the `fortls` language server with [Modern Fortran](https://marketplace.visualstudio.com/items?itemName=fortran-lang.linter-gfortran).
  - Reproducible LaTeX environment with support for [LTeX+](https://ltex-plus.github.io/ltex-plus/index.html).

<!-- - Setting up local `settings.json` for VSCode (WIP). -->
## Usage

To minimise clutter in projects, the majority of configuration is done inside a **single file** at the project root, called `config.nix`, with the `flake.nix` (and corresponding lockfile) left in the root of the directory.

0. Have `direnv` installed and that it is hooked into your shell. Have flakes enabled via some mechanism with the flag `experimental-features = nix-command flakes` e.g. in `nix.conf`.
1. Either click `Use this template` on GitHub and follow the instructions, or in a new repository, run `nix flake init -t github:chpxu/development-flake#default`.
2. In `config.nix`, define your available programming contexts, e.g.
  ```nix
  # config.nix
  {pkgs, ...}: {
    languages = { 
      # For each language inside nix/languages, a corresponding language.enable will exist!
      python = {
        enable = true; # Will enable the python devshell
      };
      tex = { # Will enable the tex devshell
        enable = true;
        ltex.enable = true;
      };
    };
  }
  ```
3. Depending on what you have enabled, you can now switch to an isolated sandbox for those languages!
  - If you enabled `python`: `nix develop .#python`
  - See `nix/languages/**/default.nix` to see the available configuration options.

Example result of `nix flake show` after enabling editor configuration, fortran and python:
```
devShells
│   ├───x86_64-darwin
│   │   ├───default omitted (use '--all-systems' to show)
│   │   ├───editorSettings omitted (use '--all-systems' to show)
│   │   ├───fortran omitted (use '--all-systems' to show)
│   │   └───python omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───default: development environment 'Blank-environment'
│       ├───editorSettings: development environment 'editorConfig'
│       ├───fortran: development environment 'fortran'
│       └───python: development environment 'python'
```

The following commands are now available!
- `nix develop .#python`
- `nix develop .#fortran`
- `nix develop .#editorConfig`


### Why you might not want to use devflake

1. It is _very_ nix-ified and there is only limited support for nix independence (e.g. using `uv` for Python or `yarn` for JavaScript); it may well not be worth your time in this case.
2. It is an opinionated abstraction layer ontop of `numtide/devshell` and `flake-parts`, and you may find that you need more of their featureset than what I provide, or you just don't like what I've done (fair enough!).
3. Unstable: this version has come fresh out of the refactor oven. I am currently working to get this refactor stable for daily usage.

## Extending devflake

Currently, devflake supports C, C++, Fortran, JS/TS, LaTeX, Python and Nix. You may use other languages than these, use packages that aren't available in nixpkgs or otherwise. This flake imports `nixos-unstable` and `nixpkgs-25.05` (mainly for some older LLVM/GCC packages). Extension can be done via traditional overlays or adding files into `/nix`. 

### Overlays
Overlays are applied on top of the **unstable** nixpkgs input only. This can be done by editing the file `overlays/default.nix`, for example to modify `ripgrep`, the file could look like this:
```nix
final: prev: {
    ripgrep = prev.ripgrep.override {
        # this is the flag specified in nixpkgs.
        withPCRE2 = false;
    };
    # Your other overlays ...
}
```
Note that overlays will most certainly trigger a package rebuild. If you attempting to modify a really big package, consider whether you really need to.

### Including other languages

First of all, thanks and I would really appreciate it if you opened a PR with this language!

1. Inside `nix/languages` folder, create a folder for your language with a `default.nix` file.
2. Inside `default.nix`, mirror the other files. A basic example could be
```nix
  # nix/languages/foo/default.nix
{
  lib,
    ...
}:
let
  t = lib.types;
in
{
    perSystem = {pkgs, config, ...}: 
    let
      cfg = config.languages.foo;
    in
    {
      # === DECLARE OPTIONS HERE
      options.languages.foo = {
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
          devshells.foo = _: {
            devshell = {
              name = "foo";
            };
            packages = [ ];
            env = [ {
              name = "DUMMY_ENV_VAR"; value = "DUMMY VALUE";
            }];
          };
        };
  };
}
```
3. Add this file to `imports` inside `flake.nix` (`vic/import-tree` automatically takes care of importing!). This then exposes `languages.foo` as an option to configure inside `config.nix`.
4. Add a generic file to each of `nix/editors/**/languages/foo.nix`, e.g.
```nix
# e.g. nix/editors/vscode/languages/foo.nix
{pkgs, ...}: {
  settings = {
    
  };
  extensions = {
    recommendations = [];
  };
}
```
This is to stop the flake from breaking (it automatically assumes these files exist once the language file has been created and tracked by git).
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

1. Have the [direnv extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) installed (either globally or in your workspace). Ensure you trust your workspace with `direnv allow .` so it can execute shell scripts. 
2. Ensure that one or both of `editors.vscode.enableSettings` and `editors.vscode.enableExtensions` are enabled in `config.nix`.
3. Once you enter your project root, run `nix develop .#editorConfig`.
4. Run `gensettings`.

This creates `.vscode/settings.json` and `.vscode/extensions.json`  in the project root directory. This is not controlled by nix and is thus editable once it has been created. You can disable the creation of one or either of these using `editors.vscode.enableSettings` and `editors.vscode.enableExtensions` to `false`.

**NOTE: you can only run `gensettings` inside the `editorConfig` devshell. If you switch to a different devshell, this functionality will NOT BE AVAILABLE until you switch back.**

The relevant files to edit are contained in `nix/editors/vscode`.
- `default.nix` contains the code which determines what settings to write, as well as the writing code itself. It uses `pkgs.writeShellScriptBin` and adds it as a package to the `editorConfig` devshell.
- `languages/<language>.nix`: files which contain 2 attribute sets: `settings` and `extensions`. The former is a JSON atom which gets written into `.vscode/settings.json`. The latter, if non-empty, will write to `.vscode/extensions.json` and will suggest extensions to install the first time you enter your workspace.

STATUS: This feature is now parity with the old code and is stable.

### (Neo)Vim (untested)

1. Install [vim-direnv](https://github.com/direnv/direnv.vim) with your plugin manager.

Launching vim from the directory of the project, after direnv has loaded, should hopefully make it pick up the right environment variables. Open an issue if it doesn't work.

STATUS: parity with stable.
### Emacs (untested)

1. Install [emacs-direnv](https://github.com/wbolster/emacs-direnv).

Launching emacs from the directory of the project, after direnv has loaded, should hopefully make it pick up the right environment variables.


STATUS: parity with stable.

## Contributing

Thanks for viewing this repo!

I don't really use anything other than NixOS and VSCode. I do not develop on Windows or Mac (even though I've enabled support for `x86_64-darwin`, this is because I expect it to function pretty much the same). Extending the flake to cope with some other editors or platforms would be greatly appreciated and would help a bunch of others if they ever happen to come across this flake and find it useful :pray:.


To contribute, please look at [extending-devflake](#extending-devflake).

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