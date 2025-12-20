{
  description = "Opinionated Flake for Fortran/Python/C/C++/JS Development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      devshell,
      git-hooks-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        ./nix/packages/python/default.nix
      ];
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          # packages = config.pre-commit.settings.enabledPackages;
          pre-commit.settings.hooks.nixfmt.enable = true;
          pre-commit.settings.hooks.nixfmt-rfc-style.enable = true;
        };

      python = {
        enable = true;
        version = "313";
        uv.enable = true;
      };
    };
}
