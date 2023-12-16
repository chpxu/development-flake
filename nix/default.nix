{
  # these first set of parameters control whether to install stuff for certain languages
  # These are not set to any defaults and are required, e.g. by calling this in `flake.nix`
  installC,
  installPython,
  installJS,
  # Allow controlling the major version of packages to be installed.
  # Allows for more flexibility when configuring the shell
  useLLVM ? true,
  llvmVer ? "17",
  pythonVer ? "310",
  nodeVer ? "20",
  # Allows the use of `misc/write_vscode_settings.nix`, which integrates nicely into VSCode configuration for the project.
  # Default false
  enableVSCodeSetup ? false,
  pkgs,
  lib,
}: let
  helper = import ./misc/helper.nix {inherit lib;};
  conditions = {
    inherit installC installPython installJS;
  };
  # Import packages
  # TODO: scan directories in ./packages automatically and return list of imports instead of manual imports
  CPackages = (import ./packages/c {inherit pkgs llvmVer;}).devCPackages;
  pythonPackages = (import ./packages/python {inherit pkgs pythonVer;}).devPythonPackages;
  jsPackages = (import ./packages/js {inherit pkgs nodeVer;}).jsPackages;
  # packages = helper.importNixFiles ./packages;
  # Create final list of packages to be made available in the shell
  listOfFinalPackages = {
    installC = CPackages;
    installPython = pythonPackages;
    installJS = jsPackages;
  };

  finalPackage =
    (helper.conditionalMerge {
      conditions = conditions;
      setOfPackages = listOfFinalPackages;
    })
    .finalList;
  # finalPackages = listOfFinalPackages.installPython;
in {
  # imports = [
  #   (./misc/write_vscode_settings.nix {
  #     inherit pkgs installC installPython installJS;
  #     pythonEnv = pythonPackages;
  #   })
  # ];
  # These attributes are exposed when called from flake.nix
  # This means configuration can be left to inside the nix directory.
  packages = finalPackage;
  # Controls whether to override the stdenv with clang or gcc
  shellOverride = {packages ? [], ...} @ shellArgs:
    if useLLVM
    then
      pkgs.mkShell.override {stdenv = pkgs.clangStdenv;} {
        inherit packages;
        buildInputs = shellArgs.buildInputs;
      }
    else
      pkgs.mkShell.override {stdenv = pkgs.gccStdenv;} {
        inherit packages;
        buildInputs = shellArgs.buildInputs;
      };
  # Controls shellHook
  shellHook = ''
    echo "Loaded direnv environment with:"
    echo "C/C++: ${installC}"
    echo "Python: ${installPython}"
    echo "Node: ${installJS}"
    ${
      if installPython
      then ''export PYTHONPATH=${pythonPackages}/${pythonPackages.sitePackages}''
      else ''''
    }
    ${
      if enableVSCodeSetup
      then ''
        echo "Setting up VSCode settings."
         cat << EOF > .vscode/settings.json
          ${(import ./misc/write_vscode_settings.nix).settings}
          EOF
      ''
      else ''echo "No VSCode settings were written"''
    }
  '';
}
