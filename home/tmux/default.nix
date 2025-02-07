{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  home.file.".config/tmux" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
