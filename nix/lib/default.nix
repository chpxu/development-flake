{ pkgs, inputs, lib, ... }:
{
  # bulkImportFromFileDirectory :: (path: String, attrs: AttrSet) -> [Path] -> [[Package]] -> [Package]
  bulkImportFromFileDirectory =
    {
      path,
      attrs,
      ...
    }@args:
    rec {
      allFilePaths = (inputs.import-tree.withLib pkgs.lib).leafs path;
      importFromFiles = map (path: (import path { inherit (args) attrs; }).packages) allFilePaths;
      allPackages = builtins.concatLists importFromFiles;
    };

  # genOptionalsFromConfig
  # :: {
  #     conditional :: AttrSet -> Bool,
  #     path:: Path
  #     target :: [String]
  #
  #   } -> (map ((f :: AttrSet -> Bool) -> a)  -> [a])
  #
  genOptionalsFromConfig = {conditional, path, target}: map (x: lib.optionals (conditional x) path) target;
}
