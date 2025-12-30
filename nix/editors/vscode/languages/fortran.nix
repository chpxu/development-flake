{
  config,
  pkgs,
  ...
}:
let
  cfg = config.languages.fortran;
in
{
  settings = {
    "fortran.linter.includePaths" = [
      "\${workspaceFolder}/include/**"
      "\$DEVSHELL_DIR/include/**"
    ];
    "fortran.linter.extraArgs" = [
      "-fdefault-real-8"
      "-fdefault-double-8"
      "-Wunused-variable"
      "-Wunused-dummy-argument"
    ];
    "fortran.linter.compiler" = "gfortran"; # Nixpkgs only has gfortran
    "fortran.linter.compilerPath" = "${cfg.package}/bin/gfortran";
    "fortran.formatting.formatter" = "fprettify"; # Only fprettify is in nixpkgs right now, and I prefer it anyways
    "fortran.formatting.path" = "${pkgs.fprettify}";
    "fortran.provide.symbols" = "fortls";
    "fortran.preferredCase" = "lowercase"; # I prefer lowercase but uppercase is an option too
  };
  extensions = {
    recommendations = [
      "fortran-lang.linter-gfortran"
      "ms-vscode.cpptools" # For debugging
      "vadimcn.vscode-lldb" # For debugging
      "tamasfe.even-better-toml" # for Fortran Package Manager TOML files;
    ];
  };
}
