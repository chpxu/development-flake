{ lib, ... }:
let
  t = lib.types;
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      cfg = config.languages;
      cfgcode = config.editors.vscode;
      getEnabledLanguages = builtins.concatMap (
        lang: lib.optional cfg.${lang}.enable ./languages/${lang}.nix
      ) (builtins.attrNames cfg); # get array of file paths for activated environments
      genSettings = map (file: (import file { inherit pkgs config lib; }).settings) (
        getEnabledLanguages
      ); # list of attrset
      genExtensions = map (file: (import file { inherit pkgs config lib; }).extensions) (
        getEnabledLanguages
      ); # list of attrset
      settingsToJSON = builtins.toJSON (lib.mergeAttrsList genSettings); # form one giant setting attrset
      extensionsToJSON = builtins.toJSON (lib.mergeAttrsList genExtensions);
      #  = ;
      settingsScript = pkgs.writeShellScriptBin "settings.sh" (''
        #!/bin/bash 
        echo "Writing VSCode settings and extensions to the project root directory/.vscode"
        if [ ! -e ".vscode" ]; then
          mkdir -p "./.vscode"
        fi

        cat << EOF > .vscode/settings.json
        ${if cfgcode.enableSettings then (builtins.toString settingsToJSON) else "{}"}
        EOF
        
        echo "VSCode settings have been successfully written"

        cat << EOF > .vscode/extensions.json
        ${if cfgcode.enableExtensions then (builtins.toString extensionsToJSON) else "{ \"recommendations\" = []}"}
        EOF
        echo "VSCode extensions.json have been successfully written"
      '');
    in
    {
      # We add settings depending on which languages are enabled
      # Import configuration from ./languages/<language>.nix
      options.editors.vscode = {
        enableSettings = lib.mkOption {
          type = t.bool;
          default = true;
          description = "Allow writing `.vscode/settings.json` for per-project configuration.";
        };
        enableExtensions = lib.mkOption {
          type = t.bool;
          default = true;
          description = "Allow writing `.vscode/extensions.json` to allow extension recommendations for languages.";
        };
      };
      config = lib.mkIf (cfgcode.enableSettings or cfgcode.enableExtensions) {
        devshells.editorSettings = {
          devshell = {
            name = "editorConfig";
            packages = [ settingsScript ];
          };
          commands = [
            {
              name = "gensettings";
              command = ''
                ${settingsScript}/bin/settings.sh
              '';
              help = "Command to generate .vscode/settings.json and .vscode/extensions.json";
            }
          ];
        };
      };
    };
}
