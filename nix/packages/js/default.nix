{
  pkgs,
  nodeVer,
  ...
}: {
  jsPackages = with pkgs; ["nodejs_${nodeVer}" yarn];
}
