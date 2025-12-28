{ inputs, ... }:
{
  bulkImportFromFileDirectory =
    {
      pkgs,
      path,
      attrsInherit,
      ...
    }@args:
    rec {
      allFilePaths = (inputs.import-tree.withLib pkgs.lib).leafs path;
      importFromFiles = map (path: (import path { inherit (args) attrsInherit; }).packages) allFilePaths;
      allPackages = builtins.concatLists importFromFiles;
    };
}
