{pythonPackages, ...}: {
  packages =  
    with pythonPackages; [
      numpy
      scipy
      sympy
    ];
}
