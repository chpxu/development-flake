{ lib, ... }:

let
  t = lib.types;

in
{
  perSystem =
    {
      pkgs,
      pkgsOlder,
      config,
      helper,
      ...
    }:
    let
      cfg = config.languages.fortran;
      minGCC = 9;
      maxGCC = 15;
    in
    {
      options.languages.fortran = {
        enable = lib.mkEnableOption "Enable Fortran in the environment.";

        gfortran = lib.mkOption {
          type = t.submodule {
            options = {
              version = lib.mkOption {
                # You may wish to use an older nixpkgs commit (e.g. 25.05) and change these so it works with your needs
                # NixOS 25.05 is the last version to support GCC 9 - 12. This is included in this flake for backwards compat.
                type = t.ints.between minGCC maxGCC;
                default = maxGCC;
                description = "The gfortran version to use. Defaults to GCC ${builtins.toString maxGCC}. NixOS 25.05 is the last version to support gfortran 9 through to 12.";
              };
            };
          };
          default = {
            version = 15;
          };
          description = "The gfortran version to use.";
        };
        debugger = lib.mkOption {
          type = t.package;
          default = pkgs.gdb;
          description = "The debugger to use.";
        };
      };

      config = lib.mkIf cfg.enable {
        devshells.fortran =
          _:
          let
            selectGCC = helper.selectFromOlderPkgsInt {
              inherit lib pkgs pkgsOlder;
              packageName = "gfortran";
              versionCriterion = 13;
              versionConfig = cfg.gfortran.version;
            };

          in
          {
            devshell = {
              name = "fortran";
            };
            packages =
              with pkgs;
              [
                fortran-fpm
                fortls
                fprettify
              ]
              ++ [cfg.debugger selectGCC];
          };

      };
    };

}
