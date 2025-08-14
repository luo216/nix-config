# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  rofi = import ./rofi.nix;
  fcitx5 = import ./fcitx5.nix;
  dunst = import ./dunst.nix;
  dwm = import ./dwm.nix;
  rainbarf = import ./rainbarf.nix;
  tmux = import ./tmux.nix;
  customYazi = import ./yazi.nix;
  customZsh = import ./zsh.nix;
  templates = import ./templates.nix;
}
