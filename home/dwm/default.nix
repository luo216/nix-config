{ config, pkgs, specialArgs, ... }:

{
  home.packages = with pkgs; [
    st
    feh
    xclip
    xdotool
    (dwm.override {
      conf = ./${specialArgs.hostname}/config.h;
    })
  ];

  home.file = {
    ".config/dwm/autostart.sh" = {
      source = ./${specialArgs.hostname}/autostart.sh;
    };
    ".local/share/wallpaper/001.png" = {
      source = ./wallpaper/001.png;
    };
  };
}
