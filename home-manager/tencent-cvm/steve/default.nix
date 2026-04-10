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
    outputs.homeManagerModules.customZsh
  ];

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
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
    wget
  ];

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

  home.stateVersion = "25.11";
}
