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

  # Simple function to replace easy if-then-else statements
  ifString = condition: success: failure:
    if condition
    then success
    else failure;
  # recursiveMergeAttr accepts one argument: setOfSets
  #  We define this type Configurable :: types.set
  # Inside Configurable, there can be an arbitrary number of attribute names with corresponding attribute values.
  # attributeName :: types.string  = attributeValues :: types.any (an array, string, number, boolean, set etc) which can be converted into JSON
  # setOfSets = { set1 = { attrName (types.string): attrValue (types.any); }; set2 = { ... }};
  # recursiveMergeAttr
  # recursiveMergeAttr = {setOfSets}: lib.attrsets.mapAttrsRecursive;
  # Credit: http://www.chriswarbo.net/projects/nixos/useful_hacks.html
  # importNixFiles = directory: builtins.mapAttrs (language: _: import directory + "/${language}") (lib.attrsets.filterAttrs (name: _: lib.strings.hasSuffix ".nix" name) (builtins.readDir directory));
}
