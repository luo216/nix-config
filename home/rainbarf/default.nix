{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    perl540Packages.Apprainbarf
  ];

  home.file.".config/rainbarf" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
