{
  installC,
  installPython,
  installJS,
  pythonPackages ? null,
  useLLVM,
  pkgs,
  lib,
  ...
}: let
  compilerPath =
    if useLLVM
    then pkgs.llvmPackages_latest
    else pkgs.gcc;
  CCppVScodeSettings = {
    "C_Cpp.default.cppStandard" = "c++17";
    "C_Cpp.default.compilerPath" =
      if useLLVM
      then "${compilerPath}/bin/clang++"
      else "${compilerPath}/bin/gcc";
    "C_Cpp.default.cStandard" = "c99";
    "C_Cpp.default.intelliSenseMode" =
      if useLLVM
      then "linux-clang-x64"
      else "linux-gcc-x64";
    "C_Cpp.autocompleteAddParentheses" = true;
  };
  PythonVScodeSettings = {
    "pylint.interpreter" = ["python3"];
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.completeFunctionParens" = true;
    "python.analysis.typeCheckingMode" = "strict";
    "python.defaultInterpreterPath" =
      if !(builtins.isNull pythonPackages)
      then "${pythonPackages}/bin/python"
      else "python3";
    "python.diagnostics.sourceMapsEnabled" = true;
    "python.languageServer" = "Pylance";
  };
  JSVScodeSettings = {
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
  };
in
  # This file contains the VSCode configuration (that I use), and is currently grouped per language. This can be modified to your needs.
  lib.attrsets.mergeAttrsList (
    []
    ++ (lib.optional installC CCppVScodeSettings)
    ++ (lib.optional installJS JSVScodeSettings)
    ++ (lib.optional installPython PythonVScodeSettings)
  )
