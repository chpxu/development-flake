{
  lib,
  config,
  builtins,
  ...
}:
let
  cfg = config.cpp;
  t = lib.types;
  # Take the following from numtide/devshell extra/languages/c because it's cool and I'm not sure how to use the internal files

  addLibraries = lib.length cfg.libraries > 0;
  addIncludes = lib.length cfg.includes > 0;
in
{
  options.cpp = {
    enable = lib.mkEnableOption "Enable C/C++ configuration.";
    compiler = lib.mkOption {
      type = t.enum [
        "gcc"
        "clang"
      ];
      description = "Whether to use gcc or Clang/LLVM compiler";
      default = "gcc";
    };
    gcc = lib.mkOption {
      enable = lib.mkIf cfg.compiler == "gcc";
      description = "Produces a gcc backend (i.e. nothing is done really).";
      type = t.submodule {
        version = lib.mkOption {
          # You may wish to use an older nixpkgs commit (e.g. 25.05) and change these so it works with your needs
          # NixOS 25.05 is the last version to support GCC 9 - 12. This is included in this flake for backwards compat.
          type = t.ints.between 9 15;
          default = 15;
          description = "The GCC version to use. Defaults to GCC13. NixOS 25.05 is the last version to support GCC 9  through to 12.";
        };
      };
    };
    llvm = lib.mkOption {
      enable = lib.mkIf cfg.compiler == "clang";
      description = "Produces a LLVM-compiled clang backend.";
      type = t.submodule {
        version = lib.mkOption {
          # You may wish to use an older nixpkgs commit (e.g. 25.05) and change these so it works with your needs
          # NixOS 25.05 is the last version to support LLVM 12 - 17. This is included in this flake for backwards compat.
          type = t.ints.between 12 20;
          default = 20;
          description = "The LLVM version to use. Defaults to LLVM20. NixOS 25.05 is the last version to support LLVM 12  through to 17.";
        };
        packages = lib.mkOption {
          type = t.nullOr t.listOf t.packages;
          default = null;
          description = "Install packages from llvmPackages_version";
        };
      };
    };
    cmake = lib.mkOption {
      type = t.submodule {
        options = {
          enable = lib.mkEnableOption "Adds CMake to the environment.";
          default = false;
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
      enable = lib.mkEnableOption "Install the ninja backend.";
      withCmake = lib.mkOption {
        type = t.bool;
        default = lib.mkDefault cfg.cmake.enable;
        description = "Force CMake to use Ninja via CMAKE_GENERATOR.";
      };
    };
    meson = lib.mkOption {
      enable = lib.mkEnableOption "Install the meson backend.";
    };
    gnumake = lib.mkOption {
      type = t.submodule {
        options = {
          enable = lib.mkEnableOption "Adds GNU Make to the environment.";
          default = true;
          gnumakeVersion = lib.mkOption {
            type = t.enum [
              "4.2"
              "4.4"
            ];
            description = "The GNU Make version to use, either \"4.2\" (NixOS 25.05) or \"4.4\" (NixOS 26.05 Unstable). Defaults to \"4.4\".";
          };
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
  };
  config = lib.mkIf cfg.enable {
    perSystem =
      { pkgs, pkgsOlder, ... }:
      {
        devshells.cpp =
          { extraModulesPath, ... }@args:
          let
            compiler =
              if cfg.compiler == "clang" then pkgs."clang_${cfg.llvm.version}" else pkgs."gcc${cfg.gcc.version}";
            llvmPackages =
              if lib.versionAtLeast cfg.llvm.version 17 then
                pkgs."llvmPackages_${cfg.llvm.version}"
              else
                pkgsOlder."llvmPackages_${cfg.llvm.version}";
          in
          {
            name = cfg.compiler;
            packages = [
              compiler
            ]
            ++ (lib.optionals addLibraries (map lib.getLib cfg.libraries))
            ++ (lib.optionals addIncludes ([ pkgs.pkg-config ] ++ (map lib.getDev cfg.libraries)))
            ++ lib.optional (cfg.compiler == "clang") (
              with llvmPackages;
              [
                clangUseLLVM
                bintools
                lldb
              ]
            )
            ++ lib.optional cfg.gcc.enable (
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
            ++( lib.optionals addIncludes [
              {
                name = "C_INCLUDE_PATH";
                prefix = "$DEVSHELL_DIR/include";
              }
              {
                name = "PKG_CONFIG_PATH";
                prefix = "$DEVSHELL_DIR/lib/pkgconfig";
              }
            ]);

          };
      };
  };

  # devCPackages = with pkgs;
  #   [
  #     gnumake
  #     cmake
  #     gdb
  #     boost
  #     cppcheck
  #     valgrind
  #     meson
  #     ninja
  #     runner
  #   ]
  #   ++ (lib.optional useLLVM (with pkgs; [llvm.lldb clang-tools llvm.libstdcxxClang llvm.libllvm llvm.libcxx]))
  #   ++ (
  #     lib.optional (!useLLVM) (with pkgs; [libgcc gcc binutils libcxx])
  #   );
}
