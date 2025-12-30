{
  lib,
  builtins,
  ...
}:
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
      # Take the following from numtide/devshell extra/languages/c because it's cool and I'm not sure how to use the internal files

      cfg = config.languages.cpp;
      addLibraries = lib.length cfg.libraries > 0;
      addIncludes = lib.length cfg.includes > 0;
      minUnstableGCC = 13;
      minUnstableLLVM = 18;
      minGCC = 9;
      minLLVM = 12;
      # maxGCC = builtins.head (builtins.splitVersion pkgs.gcc.version);
      # maxLLVM = builtins.head (builtins.splitVersion pkgs.clang.version);
      maxGCC = 15;
      maxLLVM = 20;
    in
    {
      options.languages.cpp = {
        enable = lib.mkEnableOption "Enable C/C++ configuration.";
        env = lib.mkOption {
          type = t.listOf t.attrs;
          default = [];
          description = "Additional environment variables to add.";
        };
        compiler = lib.mkOption {
          type = t.enum [
            "gcc"
            "clang"
          ];
          description = "Whether to use gcc or Clang/LLVM compiler";
          default = "gcc";
        };
        gcc = lib.mkOption {
          default = { };
          description = "Produces a gcc backend (i.e. nothing is done really).";
          type = t.submodule {
            options = {
              enable = lib.mkOption {
                type = t.bool;
                default = lib.mkDefault (cfg.compiler == "gcc");

              };
              version = lib.mkOption {
                # You may wish to use an older nixpkgs commit (e.g. 25.05) and change these so it works with your needs
                # NixOS 25.05 is the last version to support GCC 9 - 12. This is included in this flake for backwards compat.
                type = t.ints.between minGCC maxGCC;
                default = maxGCC;
                description = "The GCC version to use. Defaults to GCC ${builtins.toString maxGCC}. NixOS 25.05 is the last version to support GCC 9 through to 12.";
              };
            };

          };
        };
        llvm = lib.mkOption {
          default = { };
          description = "Produces a LLVM-compiled clang backend.";
          type = t.submodule {
            options = {
              enable = lib.mkOption {
                type = t.bool;
                default = !(cfg.gcc.enable);
              };
              version = lib.mkOption {
                # You may wish to use an older nixpkgs commit (e.g. 25.05) and change these so it works with your needs
                # NixOS 25.05 is the last version to support LLVM 12 - 17. This is included in this flake for backwards compat.
                type = t.ints.between minLLVM maxLLVM;
                default = maxLLVM;
                description = "The LLVM version to use. Defaults to LLVM ${builtins.toString maxLLVM}. NixOS 25.05 is the last version to support LLVM 12 through to 17.";
              };
              packages = lib.mkOption {
                type = t.listOf t.packages;
                default = [ ];
                description = "Install packages of the form llvmPackages_\${cfg.llvm.version} namespace";
              };
            };

          };
        };
        cmake = lib.mkOption {
          default = {
            enable = lib.mkDefault cfg.gnumake.enable;
            cmakeVersion = lib.mkDefault 4;
          };
          type = t.submodule {
            options = {
              enable = lib.mkEnableOption "Adds CMake to the environment.";

              cmakeVersion = lib.mkOption {
                type = t.enum [
                  3
                  4
                ];
                description = "The CMake version to use, either 3 or 4. Defaults to 4 (corresponds to CMake 4.x on NixOS Unstable). 3 corresponds to 3.31.2 on NixOS 25.05.";
              };
            };
          };
        };
        ninja = lib.mkOption {
          type = t.submodule {
            options = {
              enable = lib.mkEnableOption "Install the ninja backend.";
              withCmake = lib.mkOption {
                type = t.bool;
                default = lib.mkDefault cfg.cmake.enable;
                description = "Force CMake to use Ninja via CMAKE_GENERATOR.";
              };
            };

          };
          default = {
            enable = lib.mkDefault false;
          };
        };
        meson.enable = lib.mkEnableOption "Install the meson backend.";
        gnumake = lib.mkOption {
          type = t.submodule {
            options = {
              enable = lib.mkEnableOption "Adds GNU Make to the environment.";
              gnumakeVersion = lib.mkOption {
                type = t.enum [
                  "4.2"
                  "4.4"
                ];
                default = "4.4";
                description = "The GNU Make version to use, either \"4.2\" (NixOS 25.05) or \"4.4\" (NixOS 26.05 Unstable). Defaults to \"4.4\".";
              };
            };
          };
          default = {
            enable = lib.mkDefault (cfg.gcc.enable or cfg.cmake.enable);
          };
        };
        libraries = lib.mkOption {
          type = t.listOf t.package;
          default = [ ];
          description = "For dynamic libraries";
        };
        includes = lib.mkOption {
          type = t.listOf t.package;
          default = [ ];
          description = "Nixpkgs dependencies";
        };
      };
      config = lib.mkIf cfg.enable {
        devshells.cpp =
          { extraModulesPath, ... }:
          let
            selectGCC = helper.selectFromOlderPkgsInt {
              inherit lib pkgs pkgsOlder;
              packageName = "gcc";
              versionCriterion = minUnstableGCC;
              versionConfig = cfg.gcc.version;
            };
            llvmPackages = helper.selectFromOlderPkgsInt {
              inherit lib pkgs pkgsOlder;
              packageName = "llvmPackages_";
              versionCriterion = minUnstableLLVM;
              versionConfig = cfg.llvm.version;
            };
            selectClang = helper.selectFromOlderPkgsInt {
              inherit lib pkgs pkgsOlder;
              packageName = "clang_";
              versionCriterion = minUnstableLLVM;
              versionConfig = cfg.llvm.version;
            };
            compiler = if cfg.compiler == "clang" then selectClang else selectGCC;
          in
          {
            name = "C_C++_" + cfg.compiler;
            packages = [
              compiler
            ]
            ++ (lib.optionals addLibraries (map lib.getLib cfg.libraries))
            ++ (lib.optionals addIncludes ([ pkgs.pkg-config ] ++ (map lib.getDev cfg.libraries)))
            ++ lib.optionals (cfg.compiler == "clang") (
              with llvmPackages;
              [
                clangUseLLVM
                bintools
                lldb
              ]
            )
            ++ lib.optionals cfg.gcc.enable (
              with pkgs;
              [
                valgrind
                gdb
                bintools
              ]
            )
            ++ lib.optional cfg.ninja.enable [ pkgs.ninja ]
            ++ lib.optional cfg.meson.enable [ pkgs.meson ];
            env = [
              {
                name = "CC";
                value = if cfg.llvm.enable then "clang" else "gcc";
              }
              {
                name = "CXX";
                value = if cfg.llvm.enable then "clang++" else "g++";
              }
            ]
            ++ (lib.optionals addLibraries [
              {
                name = "LD_LIBRARY_PATH";
                prefix = "$DEVSHELL_DIR/lib";
              }
              {
                name = "LDFLAGS";
                eval = "-L$DEVSHELL_DIR/lib";
              }
              {
                name = "LIBRARY_PATH";
                eval = "-L$DEVSHELL_DIR/lib";
              }
            ])
            ++ (lib.optionals addIncludes [
              {
                name = "C_INCLUDE_PATH";
                prefix = "$DEVSHELL_DIR/include";
              }
              {
                name = "PKG_CONFIG_PATH";
                prefix = "$DEVSHELL_DIR/lib/pkgconfig";
              }
            ]) ++ cfg.env;

          };
      };
    };
}
