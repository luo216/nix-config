{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Utils
    fastfetch
    tree
    ncdu
    git
    curl
    wget
    vim

    # lazyvim dependencies
    lazygit
    fd
    fzf
    ripgrep
    nodejs_23 # preview markdown
    yarn # install markdown

    # browser
    google-chrome

    # openGL
    nixgl.nixGLIntel
  ];
}
