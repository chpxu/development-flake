{ config, lib, ... }:
let
  cfg = config.vscode;
  t = lib.types;
in
{
  options.vscode = {
    enableSettings = lib.mkOption {
      type = t.bool;
      default = true;
      description = "Allow writing `.vscode/settings.json` for per-project configuration.";
    };
    enableExtensions = lib.mkOption {
      type = t.bool;
      default = false;
      description = "Allow writing `.vscode/extensions.json` to allow extension recommendations for languages.";
    };
    # c = lib.mkOption {
    #   type = t.submodule {
    #     options = {
    #       settings = lib.mkOption {
    #         type = t.attrs;
    #         default = {};
    #         description = "Nix attribute set of VSCode JSON settings.";
    #       };
    #       extensions = lib.mkOption {
    #         type = t.listOf t.str;
    #         default = [];
    #         description = "List of VSCode extensions to recommend, in the format of author.extension name, e.g. ['dbaeumer.vscode-eslint' 'esbenp.prettier-vscode' ].";
    #       };
    #     };
    #   };
    # };
  };
  config = {
    perSystem =
      { pkgs, ... }:
      let 
        cfg = config.languages;
        getEnabledLanguages = builtins.concatMap (
          lang: lib.optional cfg.${lang}.enable ./languages/${lang}.nix
        ) (builtins.attrNames cfg); # get array of file paths for activated environments
        genSettings = map (file: (import file { inherit pkgs config lib; }).settings) (getEnabledLanguages); # list of attrset
        settingsToJSON = builtins.toJSON (lib.mergeAttrsList genSettings); # form one giant setting attrset
        #  = ;
        settingsScript = pkgs.writeShellScriptBin "settings.sh" (
            ''
              #!/bin/bash 
              echo "Writing VSCode settings and/or extensions to the project root directory"
              if [ ! -e ".vscode" ]; then
                mkdir -p "./.vscode"
              fi

              cat << EOF > .vscode/settings.json
              ${builtins.toString settingsToJSON}
              EOF
              echo "VSCode settings have been successfully written"
            ''
          );
      in
      {
        # We add settings depending on which languages are enabled
        # Import configuration from ./languages/<language>.nix
        devshells.editorSettings = {
          devshell = {
              name = "editorConfig";
            packages = [settingsScript];
            };
            commands = [
              {
                name = "gensettings";
                command = ''
                  ${settingsScript}/bin/settings.sh
                '';
                help = "Command to generate .vscode/settings.json";
              }
            ];
        };
      };
  };
}
