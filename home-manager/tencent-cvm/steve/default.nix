{
  outputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    outputs.homeManagerModules.customBase
    outputs.homeManagerModules.customCpa # CLI Proxy API
    outputs.homeManagerModules.customZsh # Shell (zsh)
    outputs.homeManagerModules.customYazi # File manager (yazi)
  ];

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
    sessionVariables = {
      TERM = "xterm-256color";
      TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/nix/var/nix/profiles/default/share/terminfo:/usr/share/terminfo";
    };
  };

  home.packages = with pkgs; [
    curl
    jq
    p7zip
    rsync
    uv
    wget
  ];

  services = {
    customCpa = {
      enable = true;
      host = "0.0.0.0";
      port = 8317;
      apiKeys = [ "TAoAN93hhVphA6sk2Jyo7y7G" ];
      managementSecretKey = "yG9O8VX0zoJjfAKNPiGJlLrG7DdVc5-J";
      allowRemoteManagement = true;
      usageStatisticsEnabled = true;
    };
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "hjzhang";
          email = "hjzhang216@gmail.com";
        };
      };
    };

    customZsh.enable = true;
    customYazi.enable = true;
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "25.11";
}