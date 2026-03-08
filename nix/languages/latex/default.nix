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
      cfg = config.languages.tex;
    in
    {
      options.languages.tex = {
        enable = lib.mkOption {
          description = "Whether to enable (La)TeX support in the environment";
          default = false;
          type = t.bool;
        };
        environment = lib.mkOption {
          type = t.package;
          default = pkgs.texliveBasic;
          description = "Which TeX environment to use, e.g. texliveMedium or tectonic, or make your own with pkgs.texlive.combine!";
        };
        ltex = lib.mkOption {
          type = t.submodule {
            options = {
              enable = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Enables LTeX support.";
              };

              package = lib.mkOption {
                type = t.nullOr t.package;
                description = "Which LTeX package to install. Prefer LTeX+.";
                default = pkgs.ltex-ls-plus;
              };
            };
          };

        };
        env = lib.mkOption {
          type = t.listOf t.attrs;
          default = [];
          description = "Additional environment variables to add.";
        };
      };
      config = lib.mkIf cfg.enable {
        devshells.tex =
          { extraModulesPath, ... }:
          let
            texEnvironment = cfg.environment or pkgs.texliveMedium;
            ltexDefault = cfg.ltex.package or pkgs.ltex-ls-plus;
          in
          {
            devshell = {
              name = "LaTeX";
            };
            packages = [
              pkgs.coreutils
              texEnvironment
            ]
            ++ lib.optionals cfg.ltex.enable [ ltexDefault ];
            env = [
              #{ name = "PATH"; value ="${pkgs.lib.makeBinPath packages}";} # set PATH to the environment tex instance
              {
                name = "TEXMFHOME";
                value = "$DEVSHELL_DIR/.cache";
              }
              {
                name = "TEXMFVAR";
                value = "$DEVSHELL_DIR/.cache/texmf-var";
              }
              {
                name = "TEXMFCACHE";
                value = "$DEVSHELL_DIR/.cache/texmf-cache";
              } # for Nix-built LaTeX projects, this is what is expected, see https://github.com/chpxu/reproducible-latex-template/blob/main/flake.nix

            ] ++ cfg.env;
          };

      };
    };
}
