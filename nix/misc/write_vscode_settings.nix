{
  installC,
  installPython,
  installJS,
  installLatex,
  pythonPackages ? null,
  useLLVM,
  pkgs,
  lib,
  ...
}: let
  C_CppVScodeSettings = {
    "C_Cpp.default.cppStandard" = "c++17";
    "C_Cpp.default.compilerPath" = (
      if useLLVM
      then "${pkgs.llvmPackages_latest.libstdcxxClang}/bin/clang++"
      else "${pkgs.gcc}/bin/gcc"
    );
    "C_Cpp.default.cStandard" = "c99";
    "C_Cpp.default.intelliSenseMode" = (
      if useLLVM
      then "linux-clang-x64"
      else "linux-gcc-x64"
    );
    "C_Cpp.autocompleteAddParentheses" = true;
  };
  PythonVScodeSettings = {
    "pylint.interpreter" = ["python3"];
    "pylint.enabled" = true;
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.completeFunctionParens" = true;
    "python.analysis.typeCheckingMode" = "strict";
    "python.defaultInterpreterPath" =
      if !(builtins.isNull pythonPackages)
      then "${pythonPackages}/bin/python"
      else "python3";
    "python.diagnostics.sourceMapsEnabled" = true;
    "python.languageServer" = "Pylance";
    # Configure extensions
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.formatOnSave" = true;
    };

    "mypy.dmypyExecutable" = "${pythonPackages}/bin/dmypy";
    "mypy.runUsingActiveInterpreter" = true;
    "mypy.enabled" = true;
  };
  JSVScodeSettings = {
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
  };
  latexSettings = (import (./. + "/../packages/latex") {inherit pkgs;}).latexVSCodeSettings;
  settings = lib.attrsets.mergeAttrsList (
    # Include empty set in case no settings wish to be written
    [{}]
    ++ (lib.optional installC C_CppVScodeSettings)
    ++ (lib.optional installJS JSVScodeSettings)
    ++ (lib.optional installPython PythonVScodeSettings)
    ++ (lib.optional installLatex latexSettings)
  );
in {
  # This file contains the VSCode configuration (that I use); and is currently grouped per language. This can be modified to your needs.
  # finalSettings is the final output (JSON string) to be inserted into settings.json
  finalSettings = builtins.toString (builtins.toJSON settings);
}
