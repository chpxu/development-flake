{pythonPackages, ...}: {
  packages =
     with pythonPackages; [
      ipykernel
      jupyter-core
      jupyterlab
      jupyterlab-server
      jupyterlab-widgets
      jupyterlab-pygments
      jupyterlab-lsp
    ];
}
