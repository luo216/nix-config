{ config, pkgs, ... }:

{
  home.file = {
    ".xinitrc" = {
      source = ./config/dotxinitrc;
    };
    ".Xresources" = {
      source = ./config/dotXresources;
    };
    ".icons/elementary" = {
      source = ./config/elementary;
      recursive = true;
    };
    ".config/wechat-universal" = {
      source = ./config/wechat-universal;
      recursive = true;
    };
  };
}
