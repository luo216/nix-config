{ pkgs, ... }:

{
  imports = [
    ../../home/core.nix

    ../../home/programs/common.nix
    ../../home/programs/fonts.nix

    ../../home/dotfiles
    ../../home/dwm
    ../../home/chrome
    ../../home/zsh
    ../../home/yazi
    ../../home/nvim
    ../../home/rofi
    ../../home/wezterm
    ../../home/rainbarf
    ../../home/thunar
    ../../home/dunst
    ../../home/tmux
    ../../home/picom
    ../../home/fcitx5
  ];

  programs.git = {
    userName = "HJ Zhang";
    userEmail = "hjzhang216@gmail.com";
  };
}
