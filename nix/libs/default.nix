{
  pkgs,
  inputs,
  lib,
  ...
}:
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
      ...
    }@args:
    rec {
      allFilePaths = (inputs.import-tree.withLib pkgs.lib).leafs path;
      doImport = importFromFiles {
        list = allFilePaths;
        targetAttr = "packages";
        inherit (args) attrs;
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
    }:
    map (x: lib.optionals (conditional x) path) target;
}
