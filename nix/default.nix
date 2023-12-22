{
  # these first set of parameters control whether to install stuff for certain languages
  # These are not set to any defaults and are required, e.g. by calling this in `flake.nix`
  installC,
  installPython,
  installJS,
  installLatex,
  # Allow controlling the major version of packages to be installed.
  # Allows for more flexibility when configuring the shell
  useLLVM ? true,
  llvmVer ? "17",
  pythonVer ? "310",
  nodeVer ? "20",
  gccVer ? "12",
  # Allows the use of `misc/write_vscode_settings.nix`, which integrates nicely into VSCode configuration for the project.
  # Default false
  enableVSCodeSetup ? false,
  pkgs,
  lib,
}: let
  helper = import ./misc/helper.nix {inherit lib;};
  conditions = {
    inherit installC installPython installJS installLatex;
  };
  # Import packages
  # TODO: scan directories in ./packages automatically and return list of imports instead of manual imports
  CPackages = (import ./packages/c {inherit pkgs useLLVM llvmVer gccVer;}).devCPackages;
  pythonPackages = (import ./packages/python {inherit pkgs pythonVer;}).devPythonPackages;
  jsPackages = (import ./packages/js {inherit pkgs nodeVer;}).jsPackages;
  latexPackages = (import ./packages/latex {inherit pkgs;}).latexPackages;
  # packages = helper.importNixFiles ./packages;
  # Create final list of packages to be made available in the shell
  listOfFinalPackages = {
    installC = CPackages;
    installPython = [pythonPackages];
    installJS = jsPackages;
    installLatex = latexPackages;
  };

  finalPackage =
    (helper.conditionalMerge {
      conditions = conditions;
      setOfPackages = listOfFinalPackages;
    })
    .finalList;
in {
  # These attributes are exposed when called from flake.nix
  # This means configuration can be left to inside the nix directory.
  packages = finalPackage;
  # Controls whether to override the stdenv with clang or gcc

  shellOverride = {packages ? [], ...} @ shellArgs: let
    mkShellArgs = stdenv:
      pkgs.mkShell.override {inherit stdenv;} {
        inherit packages;
        buildInputs = shellArgs.nativeBuildInputs;
        nativeBuildInputs = shellArgs.nativeBuildInputs;
        # Controls shellHook
        shellHook = ''
          echo "Loaded direnv environment with:"
          echo "C/C++: ${helper.ifString installC "Enabled" "Disabled"}"
          ${helper.ifString installPython ''
            export PYTHONPATH="${pythonPackages}/${pythonPackages.sitePackages}"
            echo "Python: Enabled"
          '' "Python: Disabled"}
          echo "Node: ${helper.ifString installJS "Enabled" "Disabled"}"
          ${
            if enableVSCodeSetup
            then ''
              echo "Writing VSCode settings to .vscode/settings.json in the root directory"
              if [ ! -e ".vscode" ]; then
                mkdir -p "./.vscode"
              fi
              cat << EOF > .vscode/settings.json
                ${(import ./misc/write_vscode_settings.nix {inherit pkgs lib installC installJS installPython installLatex useLLVM pythonPackages;}).finalSettings}
              EOF
              echo "VSCode settings have been successfully written"
            ''
            else "No VSCode settings were written"
          }
          export PATH=${pythonPackages}/bin/mypy:${pythonPackages}/bin/dmypy:${pythonPackages}/bin/black:$PATH
        '';
      };
  in (
    if useLLVM
    then mkShellArgs pkgs.clangStdenv
    else mkShellArgs pkgs.gccStdenv
  );
}
