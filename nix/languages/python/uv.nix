{
  python,
  pkgs,
  lib,
  config,
  ...
}:
{
  packages = [ pkgs.uv ] ++ lib.optional config.python.uv.ruff [ pkgs.ruff ];
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
