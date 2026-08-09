{ pkgs, ... }: {
  languages = {
    typst = {
      enable = true;
      tinymist.enable = true;
    };
    python = {
      enable = true;
      version = "314";
      nixPackages = with pkgs.python314Packages; [
        numpy
        scipy
        matplotlib
      ];
      extraPythonPackages = with pkgs.python314Packages; [
        numpy
        scipy
        matplotlib
      ];
    };
    cpp = {
      enable = true;
      gcc.enable = true;
      gcc.version = 15;
      cmake.enable = true;
      includes = with pkgs; [
        json_c
        curl
      ];
      libraries = with pkgs; [
        json_c
        curl
        libidn2
        zlib
      ];
    };
  };
}
