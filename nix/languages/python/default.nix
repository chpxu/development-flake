{
  lib,
  config,
  inputs,
  ...
}:
let
  t = lib.types;
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      cfg = config.languages.python;
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
        env = lib.mkOption {
          type = t.listOf t.attrs;
          default = [];
          description = "Additional environment variables to add.";
        };
        nixPackages = lib.mkOption {
          type = t.listOf t.package;
          default = [ ];
          description = "List of package attributes from python*Packages, e.g. with pythonPackages; [numpy scipy] etc.";
        };
        tools = lib.mkOption {
          default = {
            mypy = true;
          };
          type = t.submodule {
            options = {
              mypy = lib.mkOption {
                type = t.bool;
                default = true;
                description = "Whether to add mypy to the environment.";
              };
              pylance = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Whether to add the Pylance language server to VSCode.";
              };
            };
          };
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
        devshells.python =
          { extraModulesPath, ... }:
          let
            python = pkgs."python${cfg.version}";
            pythonPackages = pkgs."python${cfg.version}Packages";
            finalPythonPackages = (import ./packages.nix { inherit config pythonPackages lib; }).packages;
            evaluateUV = import ./uv.nix {
              inherit
                pkgs
                config
                python
                lib
                ;
            };
          in
          {
            devshell = {
              name = "python";
              motd = "";
            };
            packages = lib.mkMerge [
              (lib.mkIf cfg.uv.enable evaluateUV.packages)
              [ (lib.mkIf (!cfg.uv.enable) (python.withPackages (_: finalPythonPackages))) ]
            ];
            env = cfg.env ++ (evaluateUV.env);

          };
      };
    };
}
