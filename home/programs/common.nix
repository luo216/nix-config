{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Utils
    flameshot
    xdg-user-dirs
    xdg-launch
    fastfetch
    arandr
    p7zip
    btop
    tree
    ncdu
    curl
    wget
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
