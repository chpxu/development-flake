{
  python,
  pythonPackages,
  lib,
  config,
  ...
}: {
  packages =
    [python]
    ++ (with pythonPackages; [
      # Insert packages from nixpkgs here, e.g. numpy
    ])
    ++ lib.optional (builtins.elem "jupyter" config.python.package_template) (import ./default_packages/jupyter.nix)
    ++ lib.optional
    (builtins.elem "numeric"
    config.python.package_template) (import ./default_packages/numeric.nix);
}
