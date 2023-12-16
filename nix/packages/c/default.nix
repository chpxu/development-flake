{
  pkgs,
  llvmVer,
  ...
}: let
  llvm = pkgs."llvmPackages_${llvmVer}";
in {
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
}
