{
  python,
  pythonPackages,
  builtins,
  pkgs,
  lib,
  cfg,
  ...
}: {
  packages =
    [python]
    ++ (with pythonPackages; [
      # Insert packages from nixpkgs here, e.g. numpy
    ])
    ++ lib.optional builtins.elem "jupyter" cfg.default_packages (import ./default_packages/jupyter.nix)
    ++ lib.optional
    builtins.elem "numeric"
    cfg.default_packages (import ./default_packages/numeric.nix);
}
