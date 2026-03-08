{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.languages.python;
  pythonEnv = pkgs."python${cfg.version}".withPackages (_: cfg.nixPackages);
in {
  settings = {
    "pylint.interpreter" = ["python3"];
    "pylint.enabled" = true;
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.completeFunctionParens" = true;
    "python.analysis.typeCheckingMode" = "strict";
    "python.defaultInterpreterPath" = "${pythonEnv}/bin/python3";
    "python.diagnostics.sourceMapsEnabled" = true;
    "python.languageServer" = "Pylance";
    # Configure extensions
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.formatOnSave" = true;
    };

    "mypy.dmypyExecutable" = "dmypy";
    "mypy.runUsingActiveInterpreter" = true;
    "mypy.enabled" = true;
  };
  extensions = {
    recommendations =
      [
      ]
      ++ (lib.optional cfg.tools.mypy ["ms-python.mypy-type-checker"])
      ++ (lib.optional cfg.tools.pylance ["ms-python.vscode-pylance"]);
  };
}
