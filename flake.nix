{
  description = "Opinionated Flake for Python/C/C++/JS Development";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnfreePredicate = _: true;
      };
      installC = true;
      installPython = false;
      installJS = false;
      llvm = pkgs.llvmPackages_latest;
      devPythonPackages = ps:
        with ps; [
          numpy
          scipy
          matplotlib
        ];
      devCPackages = with pkgs; [
        gnumake
        cmake
        llvm.lldb
        gdb
        clang-tools
        boost
        llvm.libstdcxxClang
        cppcheck
        llvm.libllvm
        valgrind
        # runner
        llvm.libcxx
      ];
      pythonEnv = pkgs.python310.withPackages devPythonPackages;
      defaultHookTest = ''
        echo "Loaded direnv environment with:"
        echo "C/C++: ${installC}"
        echo "Python: ${installPython}"
        echo "Node: ${installJS}"
        echo "Setting up vscode settings"'';
      createHook = {setPythonPath}:
        if setPythonPath
        then ''
          ${defaultHookTest}
          PYTHONPATH=${pythonEnv}/${pythonEnv.sitePackages}
        ''
        else defaultHookTest;
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs;
          [zsh direnv]
          ++ (lib.optional installC devCPackages)
          ++ (lib.optional installPython pythonEnv)
          ++ (lib.optional installJS (with pkgs; [nodejs_20 yarn]));
      };
      shellHook = createHook {setPythonPath = installPython;};
    });
}
