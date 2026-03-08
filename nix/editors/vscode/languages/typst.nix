{config, ...}: let
  cfg = config.languages.typst;
in {
  settings = {
    "tinymist.compileStatus" = "enable";
    "tinymist.completion.postfix" = true;
    "tinymist.completion.postfixUfcsLeft" = true;
    "tinymist.completion.postfixUfcsRight" = true;
    "tinymist.completion.symbol" = "step";
    "tinymist.configureDefaultWordSeparator" = "disable";
    "tinymist.copyAndPaste" = "enable";
    "tinymist.dragAndDrop" = "enable";
    "tinymist.exportPdf" = "onType";
    "tinymist.exportTarget" = "paged";
    "tinymist.formatterIndentSize" = 2;
    "tinymist.formatterMode" = "typstyle";
    "tinymist.formatterPrintWidth" = 120;
    "tinymist.lint.enabled" = true;
    "tinymist.preview.refresh" = "onSave";
    "tinymist.preview.scrollSync" = "onSelectionChangeByMouse";
    "tinymist.previewFeature" = "enable";
    "tinymist.projectResolution" = "lockDatabase";
    "tinymist.renderDocs" = "enable";
    "tinymist.semanticTokens" = "enable";
    "tinymist.syntaxOnly" = "enable";
    "editor.defaultFormatter" = "myriad-dreamin.tinymist";
  };
  extensions = {
    recommendations = [
      "myriad-dreamin.tinymist"
    ];
  };
}
