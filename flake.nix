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

    typst.url = "github:typst/typst-flake";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs2505,
    flake-parts,
    devshell,
    import-tree,
    treefmt-nix,
    git-hooks-nix,
    typst,
    ...
  } @ inputs: let
    import-tree = inputs.import-tree;
    getLanguageDefaultNix = (import-tree.match ".*/default\\.nix") ./nix/languages;
    getEditorDefaultNix = (import-tree.match ".*/default\\.nix") ./nix/editors;
    imports = builtins.concatLists [
      [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ]
      getLanguageDefaultNix.imports
      getEditorDefaultNix.imports
    ];
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    {
      imports = imports;
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        userConfig = import ./config.nix {inherit pkgs;};
      in {
        _module.args = {
          pkgsOlder = import nixpkgs2505 {
            inherit system inputs';
          };
          helper = import ./nix/helpers;
        };
        imports = [userConfig]; # settings from config.nix defined by user
        packages.upgrade = pkgs.writeShellScriptBin "upgrade.sh" ''
            #https://stackoverflow.com/questions/2657935/checking-for-a-dirty-index-or-untracked-files-with-git
            echo "This script will attempt to 'upgrade' the devflake template with the latest release (i.e. not from the main branch)"
            sleep .5s
            echo "This is a DESTRUCTIVE OPERATION on the following files and directories: flake.nix, flake.lock, ./nix/{languages,helpers,editors/**/default.nix}. It will replace the files IN-PLACE."
            sleep .5s
            echo "config.nix will NOT BE TOUCHED, but its attributes MAY CAUSE ERRORS THE NEXT TIME YOU REBUILD."
            echo "Any configuration in overlays or the language-specific editor configurations will NOT BE TOUCHED, and hopefully should not cause any errors depending on how complex your configuration is"
            echo "This script will copy the entire nix directory, flake.nix, flake.lock and config.nix into a folder called 'nix-backup'"
            echo "This script will check if git is available from the environment, to warn of potentially untracked files. If git is not found, the script will continue assuming you have backed up everything"
            echo "This script will also check for curl. If curl is not found, the script will exit before anything happens"
            echo "????HAVE YOU BACKED UP YOUR STUFF YET????"
            read -n 1 -p "PRESS A KEY TO CONFIRM YOU HAVE BACKED UP. YOU ASSUME THE CONSEQUENCES, IF THEY HAPPEN:" tempinputvar
            # === BEGIN PROGRAM ===
            # Check git exists in the shell
            if ! command -v git >/dev/null 2>&1
            then
                echo "git could not be found"
            else
                git ls-files --others --error-unmatch . >/dev/null 2>&1; ec=$?
              if test "$ec" = 0; then
                  echo "Untracked files exist in this project. Will not risk updating template. Exiting..."
                  exit(1)
              elif test "$ec" = 1; then
                  echo "No untracked files"
              else
                  echo "Error from git ls-files"
              fi
            fi
          if ! command -v curl >/dev/null 2>&1
          then
              echo "curl could not be found, exiting"
              exit 1
          fi
          # ==== CREATING BACKUP ====
          echo "CREATING BACKUP"
          backupdir="nix-backup"
          if  [ ! -e "$backupdir" ]; then
            mkdir -p "$backupdir"
          else
            echo "nix-backup folder already exists. Delete and then re-run this script. Exiting..."
            exit 1
          fi
          # All relevant files in the template are moved to "nix-backup"
          mv flake.nix "$backupdir"
          cp config.nix "$backupdir"
          mv flake.lock "$backupdir"
          cp statix.toml "$backupdir"
          mv ./nix "$backupdir"

          # === FETCHING LATEST TEMPLATE ===
          echo "FETCHING LATEST TEMPLATE"
          # This URL will be correct once the refactor is on main branch
          #curl -sL https://api.github.com/repos/chpxu/development-flake/releases/download/TODO
          nix flake init -t github:chpxu/development-flake#default


          # === COPYING SOME CONFIG FILES BACK OVER THAT SHOULDN'T BREAK ANYTHING ===
          # There will only be non-hidden directories and files. A simple loop will suffice
            for dir in $backupdir/nix/editors/*/
            do
                languages=''${dir%*/}
                cp $languages/* "./nix/editors"
            done

          cp -r $backupdir/nix/editors/languages/* ./nix/editors/languages

          echo "SCRIPT HAS FINISHED RUNNING"
          echo "PLEASE CHECK EVERYTHING HAS WORKED"
          exit 0
        '';
        formatter = pkgs.nixfmt-rfc-style;
        pre-commit.settings.hooks = {
          nixfmt.enable = true;
          nixfmt-rfc-style.enable = true;
          flake-checker = {
            enable = true;
            after = ["nixfmt-rfc-style"];
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
              Opinionated flake for sane and configurable developer environments
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
