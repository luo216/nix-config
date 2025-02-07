{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    picom
  ];

  home.file.".config/picom" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
