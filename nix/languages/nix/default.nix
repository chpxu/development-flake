{
  perSystem =
    { pkgs, ... }:
    {
      devshells.nix = {
        devshell = {
          name = "Nix environment";
          motd = "Nix time";
        };

        packages = with pkgs; [
          nixd
          nixf-diagnose
          statix
          deadnix
        ];
      };
    };
}
