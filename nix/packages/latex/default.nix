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
      type = t.package;
      description = "Which TeX environment to use, e.g. texliveFull or tectonic, or make your own!";
      default = pkgs.texliveMedium;
    };
    ltex = lib.submodule {
      enable = lib.mkEnableOption "Enable LTeX/LTeX+ support";
      package = lib.mkOption {
        type = t.package;
        description = "Which LTeX package to install. Prefer LTeX+.";
        default = pkgs.ltex-ls-plus;
      };
    };
  };
  config.tex = lib.mkIf cfg.enable {
    perSystem =
      { pkgs, ... }: rec
      {
        packages = [pkgs.coreutils cfg.environment] ++ lib.optionals cfg.ltex.enable [cfg.ltex.package];
        env = [
{ name = "PATH"; value ="${pkgs.lib.makeBinPath packages}";} # set PATH to the environment tex instance
{ name = "TEXMFHOME"; value = ".cache";}
{ name = "TEXMFVAR"; value = ".cache/texmf-var";} # for Nix-built LaTeX projects, this is what is expected, see https://github.com/chpxu/reproducible-latex-template/blob/main/flake.nix

        ];
      };
  };
}
