{pkgs, ...}: let
  # Replace this with command for your external PDF viewer
  externalPDFViewer = "zathura";
in {
  # LaTeX Configuration: LuaLaTeX, BibLaTeX.
  # Use ChkTeX, LTeX, LaCheck.
  # Main usage: academic reports/papers/assignments
  # Installs full TeXLive to not worry about dependencies.
  latexPackages = with pkgs; [texliveFull jdk21 ltex-ls];
  latexVSCodeSettings = {
    # Configuration for LaTeX Workshop and LTeX.
    "latex-workshop.hover.preview.enabled" = true;
    "latex-workshop.hover.preview.mathjax.extensions" = [
      "amscd"
      "bbox"
      "boldsymbol"
      "braket"
      "cases"
      "colortbl"
      "mathtools"
      "physics"
      "unicode"
      "upgreek"
    ];
    "latex-workshop.intellisense.citation.backend" = "biblatex";
    "latex-workshop.latex.autoBuild.run" = "onSave";
    "latex-workshop.latex.recipes" = [
      {
        "name" = "lualatex ➞ biber ➞ lualatex -> lualatex";
        "tools" = ["lualatex" "biber" "lualatex"];
      }
    ];
    "latex-workshop.latex.rootFile.doNotPrompt" = true;
    "latex-workshop.latex.tools" = [
      {
        "name" = "lualatex";
        "command" = "lualatex";
        "args" = [
          "-synctex=1"
          "-interaction=nonstopmode"
          "-file-line-error"
          "-output-format=pdf"
          "-output-directory=%OUTDIR%"
          "%DOC%"
        ];
        "env" = {"TEXMFHOME" = "${pkgs.texliveFull}";};
      }
      {
        "command" = "biber";
        "name" = "biber";
        "args" = ["%DOCFILE%"];
      }
    ];
    "latex-workshop.linting.chktex.enabled" = true;
    "latex-workshop.linting.chktex.exec.args" = [
      "-wall"
      "-n22"
      "-n21"
      "-n30"
      "-e16"
      "-q"
    ];
    "latex-workshop.linting.lacheck.enabled" = true;
    "latex-workshop.texcount.autorun" = "onSave";
    "latex-workshop.view.pdf.external.synctex.args" = [
      "--synctex-forward=%LINE:0:%TEX%"
      "%PDF%"
    ];
    "latex-workshop.view.pdf.external.synctex.command" = externalPDFViewer;
    "latex-workshop.view.pdf.external.viewer.args" = [
      "--synctex-editor-command"
      "code --no-sandbox --reuse-window -g \"%{input}:%{line}\""
      "%PDF%"
    ];
    "latex-workshop.view.pdf.external.viewer.command" = externalPDFViewer;
    "latex-workshop.view.pdf.viewer" = "tab";
    "ltex.dictionary" = {
      "en" = ["monic" "infimum" "supremum" "bolzano" "weierstrass" "euler"];
    };
    "ltex.enabled" = true;
    "ltex.language" = "en-GB";
    "ltex.ltex-ls.path" = "${pkgs.ltex-ls}";
    "ltex.statusBarItem" = true;
    "ltex.additionalRules.motherTongue" = "en-GB";
    "ltex.java.path" = "${pkgs.jdk21}";
  };
}
