{
  outputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    outputs.homeManagerModules.base
    outputs.homeManagerModules.cpa
    outputs.homeManagerModules.customYazi
    outputs.homeManagerModules.customZsh
  ];

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
    sessionVariables = {
      TERM = "xterm-256color";
      TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/nix/var/nix/profiles/default/share/terminfo:/usr/share/terminfo";
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
  };

  home.packages = with pkgs; [
    curl
    git
    jq
    p7zip
    rsync
    uv
    wget
  ];

  programs.customYazi.enable = true;

  home-manager.cpa = {
    enable = true;
    host = "0.0.0.0";
    port = 8317;
    apiKeys = [ "TAoAN93hhVphA6sk2Jyo7y7G" ];
    managementSecretKey = "yG9O8VX0zoJjfAKNPiGJlLrG7DdVc5-J";
    allowRemoteManagement = true;
    usageStatisticsEnabled = true;
  };

  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

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

  home.stateVersion = "25.11";
}
