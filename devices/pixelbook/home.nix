{ pkgs, ... }:

{
  imports = [
    ../../home/core.nix

    ../../home/programs/common.nix
    ../../home/programs/fonts.nix
    ../../home/dwm
    ../../home/rofi
    ../../home/wezterm
    ../../home/tmux
  ];

  programs.git = {
    userName = "HJ Zhang";
    userEmail = "hjzhang216@gmail.com";
  };
}
