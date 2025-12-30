{
  config,
  lib,
  ...
}:
let
  cfg = config.languages.cpp;
in
{
  settings = {
    "C_Cpp.default.cppStandard" = "c++17";
    "C_Cpp.default.compilerPath" = (
      if cfg.llvm.enable then "${cfg.compiler}/bin/clang" else "${cfg.compiler}/bin/gcc"
    );
    "C_Cpp.default.cStandard" = "c23";
    "C_Cpp.default.intelliSenseMode" = (if cfg.llvm.enable then "linux-clang-x64" else "linux-gcc-x64");
    "C_Cpp.autocompleteAddParentheses" = true;
  };
  extensions = {
    recommendations = [
      "cschlosser.doxdocgen"
      "ms-vscode.cpptools"
      "franneck94.c-cpp-runner"
    ]
    ++ lib.optional cfg.cmake.enable [ "ms-vscode.cmake-tools" ]
    ++ lib.optional cfg.meson.enable ["mesonbuild.mesonbuild"]
    ++ lib.optional cfg.meson.enable ["mesonbuild.mesonbuild"]
    ++ lib.optional cfg.gnumake.enable ["ms-vscode.makefile-tools"];
  };
}
