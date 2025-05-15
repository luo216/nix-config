{ pkgs, ... }:

{
  imports = [
    ../../home/core.nix

    ../../home/programs/common.nix
    ../../home/programs/arch.nix
    ../../home/programs/applet.nix
    ../../home/programs/theme.nix
    ../../home/programs/fonts.nix
    ../../home/programs/zsh.nix

    ../../home/dotfiles
    ../../home/localBin
    ../../home/dwm
    ../../home/lazygit
    ../../home/kitty
    ../../home/yazi
    ../../home/nvim
    ../../home/rofi
    ../../home/rainbarf
    ../../home/thunar
    ../../home/dunst
    ../../home/tmux
    ../../home/picom
    ../../home/fcitx5
  ];
}
