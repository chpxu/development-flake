{
    perSystem =
        { pkgs, ... }:
        {
            devshells.default = {
                devshell = {
                    name = "Blank environment";
                    motd = "Welcome to this blank devshell!";
                };

                packages = with pkgs; [
                    # Search for available packages on https://search.nixos.org/packages

                ];
            };
        };
}