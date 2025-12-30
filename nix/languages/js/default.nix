{
  lib,
  ...
}:
let

  t = lib.types;
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      cfg = config.languages.js;
      minNode = 20;
      maxNode = 25;
    in
    {
      options.languages.js = {
        enable = lib.mkOption {
          type = t.bool;
          default = false;
          description = "Enable JS in the environment.";
        };
        asdf = lib.mkOption {
          type = t.bool;
          description = "Whether to enable the asdf-version manager, The Multiple Runtime Version Manager for managing NodeJS projects.";
          default = false;
        };
        nodeVersion = lib.mkOption {
          type = t.enum [
            20
            22
            24
          ]; # Current available versions in NixOS 25.05 and later.
          default = 20;
        };
        nodePackages = lib.mkOption {
          # I would discourage installing from nixpkgs due to lack of packages
          # and they are often out of date.
          # I personally just use the package manager, a node version and let yarn do the rest.
          type = t.listOf t.package;
          description = "Node.js packages from nixpkgs.";
          default = [ ];
        };
        corepack = lib.mkOption {
          default = {
            enable = false;
            version = cfg.nodeVersion;
          };
          type = t.submodule {
            options = {
              enable = lib.mkOption {
                type = t.bool;
                default = false; # This is Yarn 4+
                description = "Node.js Corepack is consists of wrappers for npm, pnpm and Yarn.";
              };
              version = lib.mkOption {
                type = cfg.nodeVersion.type; # Current available versions in NixOS 25.05 and later.
                default = cfg.nodeVersion;
              };
            };
          };
        };
        packageManager = lib.mkOption {
          type = t.package;
          default = pkgs.yarn-berry_4; # This is Yarn 4+
        };
        env = lib.mkOption {
          type = t.listOf t.attrs;
          default = [];
          description = "Additional environment variables to add.";
        };
      };
      config = lib.mkIf cfg.enable {
        devshells.js = _: {
          devshell = {
            name = "js/node";
            motd = "";
          };
          packages =
            [ ]
            # If we have asdf and no corepack, we disallow installing  nodejs from nixpkgs and allow installing package manager
            # If we have no asdf and yes corepack, do allow installing node from nixpkgs but disallow installing package manager from nixpkgs
            # If we have (no asdf) and (no corepack), install both node and package manager
            ++ lib.optionals (cfg.asdf && !cfg.corepack.enable) (
              builtins.concatLists [
                [
                  pkgs.asdf-vm
                  cfg.packageManager
                ]
                cfg.nodePackages
              ]
            )
            ++ lib.optionals (!cfg.asdf && cfg.corepack.enable) [
              pkgs."corepack_${builtins.toString cfg.corepack.version}"
            ]
            ++ lib.optionals (!cfg.asdf && !cfg.corepack.enable) (
              builtins.concatLists [
                [
                  pkgs."nodejs_${builtins.toString cfg.nodeVersion}"
                  cfg.packageManager
                ]
                cfg.nodePackages
              ]
            );
          env = lib.optionals cfg.asdf [
            {
              # https://asdf-vm.com/guide/getting-started.html
              name = "ASDF_DATA_DIR";
              value = "$PRJ_ROOT/.asdf"; # Normally set to "$HOME/.asdf", but to avoid conflicts it is probably safer to put it in project directory. NOT $DEVSHELL_DIR as that is read-only
            }
            {
              name = "PATH";
              value = "\${ASDF_DATA_DIR:-$PRJ_ROOT/.asdf}/shims:$PATH";
            }
          ]
          ++ lib.optionals cfg.corepack.enable [
            {
              name = "COREPACK_HOME";
              value = "$PRJ_ROOT/.cache/node/corepack";
            }
          ] ++ cfg.env;
        };
      };
    };
}
