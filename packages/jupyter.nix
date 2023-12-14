{pkgs, ...}: {
  jupyterpkgs = with pkgs.python311Packages; [
    ipykernel
    jupyter-core
    jupyterlab
    jupyterlab_server
    jupyterlab-widgets
    jupyterlab-pygments
    jupyterlab_launcher
    jupyterlab-lsp
  ];
}
