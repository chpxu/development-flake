{
  pkgs,
  nodeVer,
  ...
}: {
	# Add any relevant packages to the first list
	# Due to resolution issues, the nodejs package must be specifically called as 
	# pkgs."nodejs_${nodeVer}"
  jsPackages = with pkgs; [yarn] ++ [pkgs."nodejs_${nodeVer}"];
}
