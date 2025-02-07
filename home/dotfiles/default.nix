{ config, pkgs, ... }:

{
  home.file = {
    ".xinitrc" = {
      source = ./config/dotxinitrc;
    };
    ".Xresources" = {
      source = ./config/dotXresources;
    };
  };
}
