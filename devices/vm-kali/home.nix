{ pkgs, ... }:

{
  imports = [
    ../../home/core.nix

    ../../home/programs/common.nix
    ../../home/programs/applet.nix
    ../../home/programs/theme.nix
    ../../home/programs/fonts.nix
    ../../home/programs/zsh.nix

    ../../home/dotfiles
    ../../home/lazygit
    ../../home/yazi
    ../../home/nvim
    ../../home/rainbarf
    ../../home/dunst
    ../../home/tmux
    ../../home/fcitx5
  ];
}
