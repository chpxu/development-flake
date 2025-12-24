{
  description = "Opinionated Flake for Fortran/Python/C/C++/JS Development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2505.url = "github:NixOS/nixpkgs/2b0d2b456e4e8452cf1c16d00118d145f31160f9"; # to use for older packages
    flake-parts.url = "github:hercules-ci/flake-parts/a34fae9c08a15ad73f295041fec82323541400a9";
    devshell.url = "github:numtide/devshell/17ed8d9744ebe70424659b0ef74ad6d41fc87071";
    git-hooks-nix.url = "github:cachix/git-hooks.nix/b68b780b69702a090c8bb1b973bab13756cc7a27";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2505,
      flake-parts,
      devshell,
      git-hooks-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        ./nix/languages/python/default.nix
        ./nix/languages/latex/default.nix
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
          # config._module.args = [builtins];
          formatter = pkgs.nixfmt-rfc-style;
          # packages = config.pre-commit.settings.enabledPackages;
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            nixfmt-rfc-style.enable = true;
            flake-checker = {
              enable = true;
              after = [ "nixfmt-rfc-style" ];
            };
          };

        };
    };
}
