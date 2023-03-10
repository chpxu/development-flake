{
  description = "Typical Python Project Flake for uni";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = [pkgs.bashInteractive];
      };
      shellHook = ''
        pip install --upgrade pip
        pip install -r requirements.txt
        echo "Libraries installed"
      '';
    });
}
