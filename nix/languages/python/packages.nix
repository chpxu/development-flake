{
  pythonPackages,
  config,
  lib,
  ...
}:
let
  cfg = config.languages.python;
  # Get (alpha-sorted) list of tools
  # For each one, optionally return the package -> list of pythonPackages
  genOptionals = map (tool: lib.optionals cfg.tools.${tool} pythonPackages.${tool}) (
    builtins.attrNames cfg.tools
  );
  concatOptionals = genOptionals; # flattened list of pythonPackages
in
{
  packages = builtins.concatLists [
    cfg.nixPackages
    concatOptionals
  ];

}
