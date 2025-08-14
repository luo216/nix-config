# VM test configuration
{
  pkgs,
  ...
}:

{
  # ============ Boot 配置 ============
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  swapDevices = [ { device = "/dev/vda2"; } ];

  # ============ Networking 配置 ============
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # ============ System 配置 ============
  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  # ============ Locale 配置 ============
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  # ============ Users 配置 ============
  users.users.steve = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiJmOfDs7q5HatKbKa5G5c/cfBE3NlTUikLVzGa125n hjzhang216@gmail.com"
    ];
  };

  # ============ Programs 配置 ============
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
