{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    yazi
  ];

  home.file.".config/yazi" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
