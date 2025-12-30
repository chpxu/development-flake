rec {
  importFromFiles =
    {
      list,
      attrs,
      targetAttr,
    }@args:
    map (path: (import path { inherit (args) attrs; }).${targetAttr}) list;
  # bulkImportFromFileDirectory :: (path: String, attrs: AttrSet) -> [Path] -> [[Package]] -> [Package]
  bulkImportFromFileDirectory =
    {
      path,
      attrs,
      inputs,
      lib,
      ...
    }:
    rec {
      allFilePaths = (inputs.import-tree.withLib lib).leafs path;
      doImport = importFromFiles {
        list = allFilePaths;
        targetAttr = "packages";
        inherit attrs;
      };
      allPackages = builtins.concatLists doImport;
    };

  # genOptionalsFromConfig
  # :: {
  #     conditional :: AttrSet -> Bool,
  #     path:: Path
  #     target :: [String]
  #
  #   } -> (map ((f :: AttrSet -> Bool) -> a)  -> [a])
  #
  genOptionalsFromConfig =
    {
      conditional,
      path,
      target,
      lib,
      ...
    }:
    map (x: lib.optionals (conditional x) path) target;

  selectFromOlderPkgs =
    {
      lib,
      pkgs,
      pkgsOlder,
      packageName,
      versionCriterion,
      versionConfig,
    }:
    if lib.versionAtLeast versionConfig versionCriterion then
      pkgs."${packageName}${builtins.toString versionConfig}"
    else
      pkgsOlder."${packageName}${versionConfig}";
  selectFromOlderPkgsInt =
    {
      lib,
      pkgs,
      pkgsOlder,
      packageName,
      versionCriterion,
      versionConfig,
    }:
    if versionConfig < versionCriterion then
      pkgsOlder."${packageName}${builtins.toString versionConfig}"
    else
      pkgs."${packageName}${builtins.toString versionConfig}";
}
