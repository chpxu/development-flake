{
  python,
  pkgs,
  lib,
  cfg,
  ...
}: {
  packages = [pkgs.uv] ++ lib.optional cfg.uv.ruff [pkgs.ruff];
  env = [
    # https://wiki.nixos.org/wiki/Python#using_uv
    {
      name = "UV_PYTHON_DOWNLOADS";
      value = "never";
    }
    {
      name = "UV_PYTHON";
      value = python.interpreter;
    }
  ];
}
