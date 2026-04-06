{
  pkgs,
  user,
  ...
}:
{
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "sec";
      email = "sec@sec-lab.local";
    };
  };

  # Home Manager layer: user workflow and day-to-day Web tools validated after NixOS.
  home.packages = with pkgs; [
    ffuf
    gobuster
    httpx
    jq
    neovim
    nikto
    nuclei
    pipx
    sqlmap
    thc-hydra
    tmux
    whatweb
  ];

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
