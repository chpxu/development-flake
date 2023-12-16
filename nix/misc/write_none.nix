{pkgs}: {
  noSettings = pkgs.writeText ".vscode/settings.json" (builtins.toJSON {});
}
