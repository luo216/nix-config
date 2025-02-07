{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    dunst
  ];

  home.file.".config/dunst" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
