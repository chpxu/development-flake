{lib}: {
  # conditionalList will merge 2 lists together depending on whether a condition is true
  conditionalList = {
    condition,
    list,
    defaultList,
  }:
    if condition
    then defaultList ++ list
    else defaultList;

  # conditionalMerge will merge an arbitrary list of packages based on whether the corresponding condition for it is true.
  # If it is true, merge the package lists together, else don't
  conditionalMerge = {
    # set of conditions: {"install<language>" = types.bool; }
    conditions,
    # set of list of packages: {"install<language>": types.listOf types.package; }
    setOfPackages,
  }: {
    #
    finalList = lib.attrsets.mapAttrsToList (language: value:
      # if value == true and language exists in setOfPackages then add to the packages, else do nothing
        if (value && (lib.hasAttrByPath [language] setOfPackages))
        then [(lib.attrVals [language] setOfPackages)]
        else [])
    conditions;
  };

  # Credit: http://www.chriswarbo.net/projects/nixos/useful_hacks.html
  # importNixFiles = directory: builtins.mapAttrs (language: _: import directory + "/${language}") (lib.attrsets.filterAttrs (name: _: lib.strings.hasSuffix ".nix" name) (builtins.readDir directory));
}
