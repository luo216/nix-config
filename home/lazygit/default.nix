{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    lazygit
  ];

  home.file.".gitconfig" = {
    source = ./config/gitconfig;
  };
}
