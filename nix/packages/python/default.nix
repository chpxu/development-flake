{
  pkgs,
  pythonVer,
  jupyter ? false,
  ...
}: let
  listOfPythonPackages = ps:
    with ps;
      [
        numpy
        scipy
        matplotlib
        pygments
        #formatter
        black
        #static type analysis
        mypy
        flake8
        # v3 of pylint is already out
        # use the version provided by VSCode extension
        # Could uncomment for other editors
        # pylint
      ]
      ++ (lib.optional jupyter (import "./jupyter.nix"));
in {
  # Turn it into a list since functions expect a list of packages
  devPythonPackages = pkgs."python${pythonVer}".withPackages listOfPythonPackages;
}
