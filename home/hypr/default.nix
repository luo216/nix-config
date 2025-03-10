{ config, pkgs, specialArgs, ... }:

{
  home.packages = with pkgs; [
    hyprland
  ];

  home.file = {
    ".config/hypr/hyprland.conf" = {
      source = ./${specialArgs.hostname}/hyprland.conf;
    };
    ".local/share/wallpaper/002.png" = {
      source = ./wallpaper/002.png;
    };
    ".config/hypr/hypr.desktop" = {
      source = ./hypr.desktop;
    };
  };
}
