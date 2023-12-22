self: super: {
  # python310 = super.python310.override {
  #   packageOverrides = pyself: pysuper: {
  #     mypy = pysuper.mypy.overrideAttrs (_: rec {
  #       version = "1.8.0";
  #       src = pysuper.pkgs.fetchFromGitHub {
  #         owner = "python";
  #         repo = "mypy";
  #         rev = "refs/tags/v${version}";
  #         hash = "sha256-1YgAswqLadOVV5ZSi5ZXWYK3p114882IlSx0nKChGPs=";
  #       };
  #     });
  #   };
  # };
}
