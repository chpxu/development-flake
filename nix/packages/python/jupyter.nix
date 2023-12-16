{}: {
  jupyterpkgs = ps:
    with ps; [
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
