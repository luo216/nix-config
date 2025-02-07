{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi
  ];

  home.file.".config/rofi" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
