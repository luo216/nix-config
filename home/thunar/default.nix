{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    xfce.thunar
  ];

  home.file.".config/Thunar" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
