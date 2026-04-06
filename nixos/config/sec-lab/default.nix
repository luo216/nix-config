# sec-lab VM base for a local Kali-like lab
{
  host,
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
    arc-theme
    bibata-cursors
    burpsuite
    curl
    firefox
    git
    metasploit
    nmap
    papirus-icon-theme
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

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;

    xserver = {
      enable = true;
      xkb.layout = "us";

      displayManager.lightdm = {
        enable = true;
        greeters.gtk.enable = true;
        background = pkgs.nixos-artwork.wallpapers.catppuccin-macchiato.gnomeFilePath;
        greeters.gtk = {
          theme = {
            package = pkgs.arc-theme;
            name = "Arc-Dark";
          };
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
          cursorTheme = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
          };
          clock-format = "%a %F %H:%M";
        };
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
        memorySize = 8192;
        cores = 4;
        diskSize = 131072;
        graphics = true;
        resolution = {
          x = 1440;
          y = 900;
        };
      };
    };
  };
}
