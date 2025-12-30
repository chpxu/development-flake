
{pkgs, ...}:{
  languages = {
    python = {
        enable = true;
    };
    tex = {
      enable = true;
      environment = pkgs.texliveBasic;
      ltex.enable = true;
    };
  };
  
}