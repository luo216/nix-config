# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    outputs.homeManagerModules.cpa
    outputs.homeManagerModules.customFonts
    outputs.homeManagerModules.fcitx5
    outputs.homeManagerModules.customKitty
    outputs.homeManagerModules.customYazi
    outputs.homeManagerModules.customZsh
    outputs.homeManagerModules.tmux
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
  };

  programs = {
    home-manager.enable = true;
    customFonts.enable = true;
    customTmux.enable = true;
    customKitty.enable = true;
    customYazi.enable = true;
    customZsh.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "kali";
          email = "kali.dev@gmail.com";
        };
      };
    };
  };

  home-manager.fcitx5 = {
    enable = true;
    theme = "gruvbox-material";
  };

  home-manager.cpa.enable = true;

  home.packages = with pkgs; [
    neovim
    git
    lazygit
    curl
    wget
    ripgrep
    fd
    fzf
    eza
    zoxide
    nodejs_24
    yarn
    uv
    unzip
    zip
    gcc
    gnumake
    python3
    tree-sitter
  ];

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
