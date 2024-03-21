{
  lib,
  langName ? "",
  enabled ? false,
  options ? {
    write_vscode_settings = false;
  },
}:
assert (builtins.isString langName) "The given language name is not a string";
assert (builtins.isBool enabled) "Language.enabled is not of type types.bool";
assert (builtins.isAttrs options) "Language.options is not of type types.attrs"; {
  "${langName}" = {
    inherit enabled options;
  };
}
