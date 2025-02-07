{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Utils
    flameshot
    ueberzugpp
    xdg-user-dirs
    xdg-launch
    fastfetch
    arandr
    tree
    ncdu
    curl
    wget
    p7zip
    mpv
    vim

    # lazyvim dependencies
    fd
    fzf
    ripgrep
    nodejs_23 # preview markdown
    yarn # install markdown

    # browser
    google-chrome

    # openGL
    # nixgl.auto.nixGLDefault
    nixgl.nixGLIntel
  ];
}
