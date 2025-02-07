{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  home.file.".config/kitty" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
