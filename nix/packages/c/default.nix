{
  pkgs,
  llvmVer,
  useLLVM,
  gccVer,
  ...
}: let
  llvm = pkgs."llvmPackages_${llvmVer}";
  gcc = pkgs."gcc${gccVer}";
  runner = pkgs.writeShellScriptBin "run" (builtins.readFile ./script.sh);
in {
  devCPackages = with pkgs;
    [
      gnumake
      cmake
      gdb
      boost
      cppcheck
      valgrind
      meson
      ninja
      runner
    ]
    ++ (lib.optional useLLVM (with pkgs; [llvm.lldb clang-tools llvm.libstdcxxClang llvm.libllvm llvm.libcxx]))
    ++ (
      lib.optional (!useLLVM) (with pkgs; [libgcc gcc binutils libcxx])
    );
}
