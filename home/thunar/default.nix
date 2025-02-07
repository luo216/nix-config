{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    xfce.thunar
  ];

  home.file.".config/Thunar/uca.xml" = {
    source = ./config/uca.xml;
    # copy the scripts directory recursively
    recursive = true;
  };
}
