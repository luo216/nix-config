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

  targets.genericLinux = {
    enable = true;
    nixGL = {
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
      vulkan.enable = true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "25.11";
}