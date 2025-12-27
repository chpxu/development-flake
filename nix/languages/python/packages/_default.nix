{pythonPackages, ...}:
{
  customPkgs =
    with pythonPackages; [
      # Insert your own custom pythonpackages here
      numpy
    ];
}