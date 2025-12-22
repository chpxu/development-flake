{
  lib,
  config,
  builtins,
  pkgs,
  ...
}:
let
  cfg = config.tex;
  t = lib.types;
in
{
  options.tex = {
    enable = lib.mkEnableOption "Whether to enable (La)TeX support in the environment";
    environment = lib.mkOption {
      type = t.nullOr t.package;
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
          };
        };
      };

    };

  };
  config = lib.mkIf cfg.enable {
    perSystem =
      { pkgs, ... }:
      rec {
        devshells.default =
          { extraModulesPath, ... }@args:
          let
            texEnvironment = cfg.environment or pkgs.texliveMedium;
            ltexDefault = cfg.ltex.package or pkgs.ltex-ls-plus;
          in
          {
            packages = [
              pkgs.coreutils
              texEnvironment
            ]
            ++ lib.optionals cfg.ltex.enable [ ltexDefault ];
            env = [
              #{ name = "PATH"; value ="${pkgs.lib.makeBinPath packages}";} # set PATH to the environment tex instance
              {
                name = "TEXMFHOME";
                value = ".cache";
              }
              {
                name = "TEXMFVAR";
                value = ".cache/texmf-var";
              }
              {
                name = "TEXMFVAR";
                value = ".cache/texmf-cache";
              } # for Nix-built LaTeX projects, this is what is expected, see https://github.com/chpxu/reproducible-latex-template/blob/main/flake.nix

            ];
          };

      };
  };
}
