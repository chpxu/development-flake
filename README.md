# Development Template with direnv

Opinionated flake for development of various things I work on using various languages/frameworks/tools.

## Workflow

This flake is intended to fit with my workflow, which is with [Visual Studio Code](https://code.visualstudio.com), NixOS and direnv. If you wish to use only to setup a reproducible, containerised development environment then:

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
  programs.direnv.enable = true;
}
```

3. Click `"Use this template"` on GitHub, then `"Create a new repository"`. Follow the steps there, then clone your repository to somewhere locally on your own system
4. Enter the repository folder.
5. Modify the flake to include what you want.
6. Run `direnv allow .` and it will drop you into the containerised environment.

## Features

- `C/C++` based off [fufexan's config](https://gist.github.com/fufexan/2e7020d05ff940c255d74d5c5e712815)
  - Summary: Clang/LLVM C/C++ development environment.
- `Python` with pre-installed packages intended for scientific work and visualisation.
  - Default packages: `numpy, scipy, matplotlib`
- `Node/JS/TS` with pre-installed packages for `nodejs, yarn`.

## Configuring for your own use

To minimise clutter with projects, the majority of configuration is done inside the `nix` folder, with the `flake.nix` (and corresponding lockfile) left in the root of the directory. This section of the README can be considered to be the "Documentation".

### Modifying `flake.nix`

The `flake.nix` file brings all the configuration together and initialises the development shell: that is its only function. You might want to modify it if you want it to build a derivation for your use case specifically, for example.

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
    │   └── overlays.nix
    └── misc/
        ├── write_vscode_settings.nix
        ├── generic.nix
        └── # other files
```

- `default.nix` is the file which imports and includes everything from all the other files and sets up package configuration, vscode configuration etc. This file is then included inside `flake.nix` to be consumed by `devShells`.
- `packages/<language>` folders contain nix files that detail the relevant packages to be installed and `shellHook` output.
- `overlays` folder contains, well, any overlays you might want to use. 
  - For example, configuring python311 to `enableOptimisations` and disable `reproducibleBuild` for potential speedups
- `misc` folder contains any general functions written to be used across the project, and any configuration that does not directly impact the shell itself (e.g. editor settings).

## Contributing

Thanks for viewing this repo¬

I don't really use anything other than NixOS and VSCode. I don't do development on Windows anymore. Extending the flake to cope with some other editors or platforms would be greatly appreciated and would help a bunch of others if they ever happen to come across this.

## Upcoming

- [ ] VSCode workspace integration (writing `.vscode/settings.json` in current directory).
- [ ] Flexibility with modules.
