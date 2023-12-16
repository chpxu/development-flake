{
  pythonEnv ? null,
  useLLVM,
  pkgs,
  lib,
  ...
}: let
  compilerPath =
    if useLLVM
    then pkgs.llvmPackages_latest
    else pkgs.gcc;
in rec {
  # This file contains the VSCode configuration (that I use), and is currently grouped per language. This can be modified to your needs.
  # It creates a final configuration based on what is used. This is an overengineered method to writing a textFile, but I feel that it is flexible in what it does and can do - it means I can write lines of settings declaratively and keep is across projects easily
  emptySettings = {};
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
    "python.analysis.typeCheckingMode" = "on";
    "python.defaultInterpreterPath" =
      if !(builtins.isNull pythonEnv)
      then "${pythonEnv}/bin/python"
      else "python3";
    "python.diagnostics.sourceMapsEnabled" = true;
    "python.languageServer" = "Pylance";
  };
  JSVScodeSettings = {
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
  };
  # This section of code creates the final nix JSON atom condtionally based on what is configured
  # conditions = [installC installPython installJS];
  # settingsList = [CCppVScodeSettings PythonVScodeSettings JSVScodeSettings];
  # settingConditionPairs = lib.zip conditions settingsList;
  # settingsToMerge = lib.mapAttrsToList mergeSetsHelper settingConditionPairs;
  # TODO: Conditionally merge attributes
  settings = builtins.toJSON (lib.attrsets.mergeAttrsList [CCppVScodeSettings PythonVScodeSettings JSVScodeSettings]);
}
