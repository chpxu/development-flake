{
  config,
  lib,
  pkgs,
  options,
  ...
} @ inputs:
with lib; let
  cfg = config.programs.direnv-dev;
  inherit (pkgs.stdenv.hostPlatform) system;
  llvm = pkgs.llvmPackages_latest;
  runner = pkgs.writeShellScriptBin "run" (builtins.readFile ./script.sh);
  envPackages = ps:
    with ps; [
      numpy
      scipy
      matplotlib
    ];
in {
  options.programs.direnv-dev = {
    enable =
      mkEnableOption null
      // {
        type = types.bool;
        default = true;
        description = mdDoc ''
          Enables the development environment to be setup with direnv.

          This package installs zsh and direnv.
        '';
      };
    installC =
      mkEnableOption null
      // {
        type = types.bool;
        default = false;
        description = ''
          Installs and sets up the C/C++ development environment
        '';
      };
    installPython =
      mkEnableOption null
      // {
        type = types.bool;
        default = false;
        description = ''
          Installs and sets up the Python development environment
        '';
      };
    installJS =
      mkEnableOption null
      // {
        type = types.bool;
        default = false;
        description = ''
          Installs and sets up a a JS/TS development environment with Node pre-installed.
        '';
      };
    config = mkIf cfg.enable {
      packages = with pkgs;
        [zsh direnv]
        ++ (lib.optional cfg.installC (with pkgs; [
          gnumake
          cmake
          llvm.lldb
          gdb
          clang-tools
          boost
          llvm.libstdcxxClang
          cppcheck
          llvm.libllvm
          valgrind
          runner
          llvm.libcxx
        ]))
        ++ (lib.optional cfg.installPython (pkgs.python310.withPackages envPackages))
        ++ (lib.optional cfg.installJS (with pkgs; [nodejs_20 yarn]));
    };
  };
}
