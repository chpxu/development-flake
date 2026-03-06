{
  lib,
  config,
  inputs,
  ...
}: let
  t = lib.types;
in {
  perSystem = {
    pkgs,
    config,
    system,
    ...
  }: let
    cfg = config.languages.typst;
  in {
    options.languages.typst = {
      enable = lib.mkOption {
        type = t.bool;
        default = false;
        description = "Enable Typst environment.";
      };
      env = lib.mkOption {
        type = t.listOf t.attrs;
        default = [];
        description = "Additional environment variables to add.";
      };
      tinymist.enable = lib.mkOption {
        type = t.bool;
        default = true;
        description = "Enable tinymist.";
      };
    };
    config = lib.mkIf cfg.enable {
      treefmt = {
        programs = {
          typstyle.enable = true;
        };
        settings.formatter = {
          typstyle = {
            priority = 1;
            options = [
              "--indent-width"
              "2"
              "--line-width"
              "120"
            ];
          };
        };
      };
      devshells.typst = {extraModulesPath, ...}: let
        typst-pkg = inputs.typst.packages.${system}.default;
      in {
        devshell = {
          name = "typst";
          motd = "LaTeX but faster?";
        };

        commands =
          [
            {
              name = "tc";
              command = ''
                typst compile "$1".typ
              '';
              help = "Shorthand for `typst compile file.typ`";
            }
            {
              name = "tw";
              command = ''
                typst watch "$1".typ
              '';
              help = "Shorthand for `typst watch file.typ`";
            }
          ]
          ++ lib.optionals cfg.tinymist.enable [
            {
              name = "tmcs";
              command = ''tinymist compile --save-lock "$1".typ'';
            }
          ];
        packages = [typst-pkg] ++ lib.optionals cfg.tinymist.enable [pkgs.tinymist];
        env =
          cfg.env
          ++ [
            # You should declare TYPST_FONT_PATHS if it is broken
          ];
      };
    };
  };
}
