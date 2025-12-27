{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (inputs) import-tree;
  cfg = config.languages.python;
  t = lib.types;
in
{
  options.languages.python = {
    enable = lib.mkOption {
      type = t.bool;
      default = false;
      description = "Enable python in the environment.";
    };
    version = lib.mkOption {
      type = t.enum [
        "310"
        "311"
        "312"
        "313"
        "314"
        "315"
      ]; # Currently supported by NixOS 26.05
      default = "312";
      description = "The python version to use in the project, e.g \"310\" corresponds to Python 3.10.";
    };
    uv = lib.mkOption {
      default = {
        enable = false;
      };
      type = t.submodule {
        options = {
          enable = lib.mkOption {
            type = t.bool;
            default = false;
            description = "Enable managing python projects with uv instead of nixpkgs";
          };
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
    perSystem =
      { pkgs, ... }:
      {
        devshells.python =
          { extraModulesPath, ... }@args:
          let
            python = pkgs."python${cfg.version}";
            pythonPackages = pkgs."python${cfg.version}Packages";
            # Get list of files
            # Define map to import each file ands the `packages` function
            # This will form a list of `packages` functios
            # Here, packages is a function so we must concat all and pass it into python.withPackages
            # Wrap this in a function so it is not always called, e.g. if we're using uv
            evaluatePackages = {}: rec {
              allPythonFilePaths = (import-tree.withLib pkgs.lib).leafs ./packages;
              importPythonEnvs = map (path: (import path { inherit pythonPackages; }).packages) allPythonFilePaths;
              allPythonPackages = builtins.concatLists importPythonEnvs;
              finalPythonEnv = python.withPackages (_: allPythonPackages);
            };
            evaluateUV = (import ./uv.nix {
                inherit
                  pkgs
                  config
                  python
                  lib
                  ;
              });
          in
          {
            devshell = {
              name = "python";
              motd = "";
            };
            packages = lib.mkMerge [
              (lib.mkIf cfg.uv.enable (evaluateUV.packages))
              (lib.mkIf (!cfg.uv.enable) (evaluatePackages {}).finalPythonEnv)
            ];
            env = evaluateUV.env or [];
          

          };
      };
  };
}
