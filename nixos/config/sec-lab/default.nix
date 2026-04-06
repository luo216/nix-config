# sec-lab VM base for a local Kali-like lab
{
  host,
  outputs,
  pkgs,
  ...
}:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  swapDevices = [ { device = "/dev/vda2"; } ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
    useDHCP = false;
    dhcpcd.enable = false;
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  console.keyMap = "us";

  users.users.sec = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
    initialPassword = "sec";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # NixOS layer: desktop/runtime/global tools verified before Home Manager.
    burpsuite
    curl
    firefox
    git
    metasploit
    nmap
    python3
    tcpdump
    wget
    wireshark
    xfce.xfce4-terminal
    xfce.thunar
    xdg-utils
    zap
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit outputs;
      inherit host;
      user = builtins.elemAt host.users 0;
    };
    users.sec = import ../../../home-manager/sec-lab/sec;
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;

    xserver = {
      enable = true;
      xkb.layout = "us";

      displayManager.lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };

      desktopManager.xfce.enable = true;
    };

    displayManager = {
      defaultSession = "xfce";
      autoLogin = {
        enable = true;
        user = "sec";
      };
    };
  };

  virtualisation = {
    vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 2;
        graphics = true;
        resolution = {
          x = 1440;
          y = 900;
        };
      };
    };
  };
}
