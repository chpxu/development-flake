# direnv-template

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

## Upcoming

- VSCode workspace integration (writing `.vscode/settings.json` in current directory).
- Flexibility with modules
