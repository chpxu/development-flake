# Development Template with direnv

Opinionated flake for development of various things I work on using multiple languages/frameworks/tools. Uses `flake-utils`, `direnv` and `nix-direnv`. The motivation for this is to create an environment which is easy to use

## Workflow

This flake is intended to fit with my workflow, which is with [Visual Studio Code](https://code.visualstudio.com), NixOS and direnv. This project is not intended to be a replacement or alternative to excellent projects such as direnv, devenv, lorri etc. The flake setups up a reproducible development environment for different programming contexts, and aims to be as declarative as possible whilst allowing some flexibility. 

To use it:

1. Install nix on your system.
2. Have [`direnv`](https://direnv.net/) installed on your system (follow their instructions). Ideally use [`nix-direnv`](https://github.com/nix-community/nix-direnv) for faster and more persistent caching. You do not need NixOS as the Nix package manager can be installed anywhere, as can `home-manager`. Example configurations:

```nix
## home-manager example configuration
# e.g. home.nix
programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh.enable = true;
  };

# ====
# System (NixOS) example configuration:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

3. Click `"Use this template"` on GitHub, then `"Create a new repository"`. Follow the steps there, then clone your repository to somewhere locally on your own system
4. Enter the repository folder.
5. Modify the flake to include what you want.
6. Run `direnv allow .` and it will drop you into the containerised environment.

## Features

- `C/C++` based off [fufexan's config](https://gist.github.com/fufexan/2e7020d05ff940c255d74d5c5e712815)
  - Summary: GCC or Clang/LLVM C/C++ development environment.
- `Python` with pre-installed packages intended for scientific work and visualisation.
  - Default packages: `numpy, scipy, matplotlib`.
  - Option for `Jupyter`.
  - Uses [black for code formatting](https://github.com/psf/black), [mypy for static type analysis](https://github.com/python/mypy) and [flake8](https://flake8.pycqa.org/en/latest/) for linting.
- `Node/JS/TS` with pre-installed packages for `nodejs, yarn`.
  - The packages installed here are minimal since I prefer to use `package.json`s for each individual project.
  - Uses Prettier for code formatting of HTML/Markdown/JS/TS/JSON etc. by default.
- `TeXLive 2022 Full`, with `LTeX-LS` and VSCode settings for `LaTeX Workshop` and `LTeX` extensions/ 
- Easy modification of development environments for each language.
<!-- - Setting up local `settings.json` for VSCode (WIP). -->
## Configuring for your own use

To minimise clutter with projects, the majority of configuration is done inside the `nix` folder, with the `flake.nix` (and corresponding lockfile) left in the root of the directory. This section of the README can be considered to be the "Documentation".

### Modifying `flake.nix`

The `flake.nix` file brings all the configuration together and initialises the development shell: that is its only function. You might want to modify it if you want it to build a derivation for your use case specifically, or change what is installed, for example.

The `nix` folder structure looks something like this:
```
.
└── nix/
    ├── default.nix
    ├── packages/
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
- `misc` folder contains any general functions written to be used across the project (`helper.nix`), and any configuration that does not directly impact the shell itself (e.g. editor settings).

### Editor/IDE Integration

Currently this is WIP, and my main goal is making sure this flake works well with VSCode.

### Visual Studio Code

1. Have the [direnv extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) installed (either globally or in your workspace). Ensure you trust your workspace so it can execute shell scripts.

The repository contains a file `misc/write_vscode_settings.nix` which converts sets of Nix expressions to a JSON string, and then writes to `.vscode/settings.json` in the directory where the flake is located. The file created *is* editable which means you can mess around with settings after the original file is created, however the file is not prettified and you may want external tools like `jq` or an extension like `Prettier` to auto-format it back to a readable state.

### (Neo)Vim

Untested, I don't use vim for serious development, so I'm unaware of many solutions.

1. Install [vim-direnv](https://github.com/direnv/direnv.vim) with your plugin manager.

### Emacs

1. Install [emacs-direnv](https://github.com/wbolster/emacs-direnv).

## Contributing

Thanks for viewing this repo!

I don't really use anything other than NixOS and VSCode. I don't do development on Windows anymore. Extending the flake to cope with some other editors or platforms would be greatly appreciated and would help a bunch of others if they ever happen to come across this.

## Other niceties

- [zsh](https://www.zsh.org/) and [starship](https://starship.rs/).
