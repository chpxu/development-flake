{
  description = "Opinionated Flake for Fortran/Python/C/C++/JS Development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2505.url = "github:NixOS/nixpkgs/2b0d2b456e4e8452cf1c16d00118d145f31160f9"; # to use for older packages
    flake-parts.url = "github:hercules-ci/flake-parts/a34fae9c08a15ad73f295041fec82323541400a9";
    devshell.url = "github:numtide/devshell/17ed8d9744ebe70424659b0ef74ad6d41fc87071";
    import-tree.url = "github:vic/import-tree/3c23749d8013ec6daa1d7255057590e9ca726646";
    git-hooks-nix.url = "github:cachix/git-hooks.nix/b68b780b69702a090c8bb1b973bab13756cc7a27";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2505,
      flake-parts,
      devshell,
      import-tree,
      treefmt-nix,
      git-hooks-nix,
      ...
    }@inputs:
    # let
    #   import-tree = inputs.import-tree;
    #   getLanguageDefaultNix = ((import-tree.match ".*/[a-z]+@(default)\.nix") ./nix/languages);
    #   imports = builtins.concatLists [
    #     [
    #       inputs.devshell.flakeModule
    #       inputs.git-hooks-nix.flakeModule
    #     ]
    #     (getLanguageDefaultNix.imports)
    #   ];
    # in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          helpers = import ./nix/helpers;
        };
      }
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.devshell.flakeModule
          inputs.treefmt-nix.flakeModule
          inputs.git-hooks-nix.flakeModule
          ./nix/languages/default
          ./nix/languages/c
          ./nix/languages/python
          ./nix/languages/latex
          ./nix/editors/vscode
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
            system,
            ...
          }:

          {
            formatter = pkgs.nixfmt-rfc-style;
            pre-commit.settings.hooks = {
              nixfmt.enable = true;
              nixfmt-rfc-style.enable = true;
              flake-checker = {
                enable = true;
                after = [ "nixfmt-rfc-style" ];
              };
              treefmt = {
                enable = true;
                package = self'.formatter;
              };

            };
            treefmt = {
              projectRootFile = "flake.nix";
              programs = {
                deadnix.enable = true;
                statix.enable = true;
                nixfmt.enable = true;
              };

              settings = {
                global.excludes = [
                  ".direnv/*"
                ];

                formatter = {
                  deadnix.priority = 1;
                  statix.priority = 2;
                  nixfmt = {
                    priority = 3;
                    strict = true;
                    indent = 2;
                  };
                };
              };
            };
          };
        flake = {
          modules = [
            {
              nixpkgs.overlays = [
                (import ./overlays)
              ];
            }
          ];
          templates = {
            default = {
              description = ''
                Opinionated flake
              '';
              path = ./.;
              welcomeText = ''
                Welcome to devflake. Edit flake.nix to get started. See the README.md for more information.
              '';
            };
          };
        };
      };
}
