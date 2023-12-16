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
      ]
      ++ (lib.optional jupyter (import "./jupyter.nix"));
in {
  # Turn it into a list since functions expect a list of packages
  devPythonPackages = [(pkgs."python${pythonVer}".withPackages listOfPythonPackages)];
}
