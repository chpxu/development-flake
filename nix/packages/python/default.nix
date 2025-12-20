# {
#   pkgs,
#   pythonVer,
#   jupyter ? false,
#   ...
# }: let
#   listOfPythonPackages = ps:
#     with ps;
#       [
#         numpy
#         scipy
#         matplotlib
#         pygments
#         #formatter
#         black
#         #static type analysis
#         mypy
#         flake8
#         # v3 of pylint is already out
#         # use the version provided by VSCode extension
#         # Could uncomment for other editors
#         # pylint
#       ]
#       ++ (lib.optional jupyter (import (./. + "/jupyter.nix")));
# in {
#   # Turn it into a list since functions expect a list of packages
#   devPythonPackages = pkgs."python${pythonVer}".withPackages listOfPythonPackages;
# }
{
  lib,
  config,
  builtins,
  ...
}: let
  cfg = config.python;
  t = lib.types;
in {
  options.python = {
    enable = lib.mkEnableOption "Enable python configuration.";
    version = lib.mkOption {
      type = t.enum ["310" "311" "312" "313" "314" "315"]; #  Currently supported by NixOS 26.05
      default = "312";
      description = "The python version to use in the project, e.g \"310\" corresponds to Python 3.10.";
    };
    package_template = lib.mkOption {
      type = t.nullOr t.listOf lib.types.str;
      default = null;
      description = "Installs default packages under various namespaces located in the folder default_packages";
    };
    uv = lib.mkOption {
      type = t.submodule {
        options = {
          enable = lib.mkEnableOption "Enable managing python projects with uv instead of nixpkgs";
          ruff = lib.mkOption {
            description = "Install the ruff linter, also by the uv developers";
            type = t.bool;
            default = false;
          };
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    perSystem = {pkgs, ...}: {
      devshells.default = {extraModulesPath, ...} @ args: let
        python = pkgs."python${cfg.version}";
        pythonPackages = pkgs."python${cfg.version}Packages";
      in (lib.mkMerge [
        (lib.mkIf cfg.uv.enable (import ./uv.nix {inherit pkgs cfg python lib;}))
        (lib.mkIf (!cfg.uv.enable) (import ./nix_python.nix {inherit pkgs cfg python lib pythonPackages builtins;}))
      ]);
    };
  };
}
