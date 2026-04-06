# Pixelbook specific configuration
{
  pkgs,
  ...
}:

{
  # ============ Boot 配置 ============
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

    kernelModules = [ "i2c-dev" ];

    resumeDevice = "/dev/mmcblk0p2";
  };

  powerManagement.enable = true;

  # ============ Networking 配置 ============
  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
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

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];

  environment.systemPackages = with pkgs; [
    sparkle
    vim
    wget
    curl
    networkmanager
    brightnessctl
    zsh
    unzip
    bubblewrap
    intel-media-driver
    ventoy
  ];

  systemd.tmpfiles.rules = [
    # Codex looks for bubblewrap at /usr/bin/bwrap on Linux systems.
    "L+ /usr/bin/bwrap - - - - ${pkgs.bubblewrap}/bin/bwrap"
  ];

  hardware.pixelbook-go-audio = {
    enable = true;
  };

  virtualisation.docker.enable = true;

  services.docker-easyconnect = {
    enable = false;
    socksPort = 1080;
    httpPort = 8888;
    vncPort = 5901;
    mode = "proxy";
    # Connect VNC to 127.0.0.1:5901 to log in to EasyConnect.
    # After login, set browser/app proxy to:
    # SOCKS5 127.0.0.1:1080
    # HTTP   127.0.0.1:8888
    vncPassword = "change-me";
  };

  security.wrappers.sparkle = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    source = "${pkgs.sparkle}/bin/sparkle";
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      source-han-sans
      source-han-serif
      source-han-mono
      noto-fonts-color-emoji
    ];
    fontconfig.enable = true;
  };

  programs = {
    kdeconnect.enable = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        glib
        openssl
        libxml2
        cairo
        pango
        fontconfig
        freetype
        libpng
        libjpeg_turbo
        sqlite
        libnotify
        icu
        libva
      ];
    };

    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  services = {
    todesk.enable = true;
    dbus.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
      ];
    };
    logind = {
      settings.Login.HandlePowerKey = "ignore";
    };
  };

  systemd.services.todeskd.serviceConfig = {
    LogsDirectory = "todesk";
    LogsDirectoryMode = "0777";
  };

  services.network-printers = {
    enable = true;
    printers = [
      {
        name = "pantum-m6760";
        description = "Pantum M6760";
        location = "Wi-Fi Direct";
        deviceUri = "ipp://192.168.223.1/ipp/print";
        model = "everywhere";
        testHosts = [
          "192.168.223.1"
        ];
        ppdOptions = {
          PageSize = "A4";
          Duplex = "None";
        };
      }
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    LIBVA_DRIVERS_PATH = "/run/current-system/sw/lib/dri";
  };

  # ============ Desktop 配置 ============
  services.xserver = {
    enable = true;

    windowManager.mydwm = {
      enable = true;
      useCustomConfig = true;
      configName = "pixelbook";
      extraSessionCommands = ''
        export PATH="$HOME/.local/bin:$PATH"
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export XMODIFIERS=@im=fcitx
        export INPUT_METHOD=fcitx
        export SDL_IM_MODULE=fcitx
        export GLFW_IM_MODULE=ibus

        nm-applet &
        blueman-applet &
      '';
    };

    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
  };

  services.displayManager = {
    defaultSession = "none+mydwm";
    autoLogin = {
      enable = true;
      user = "steve";
    };
  };

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = false;
      clickMethod = "clickfinger";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.blueman.enable = true;

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 48;
    };
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    targets = {
      gtk.enable = true;
      qt.enable = true;
    };
  };

  home-manager.users.steve.stylix.targets = {
    dunst.enable = false;
    fcitx5.enable = false;
    kitty.enable = false;
    rofi.enable = false;
    tmux.enable = false;
    yazi.enable = false;
  };

  services.udisks2.enable = true;

  # ============ Locale 配置 ============
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ============ Users 配置 ============
  users.users.steve = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
    ];
  };

}
