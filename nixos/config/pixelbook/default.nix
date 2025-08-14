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

  environment.systemPackages = with pkgs; [
    sparkle
    vim
    wget
    curl
    networkmanager
    networkmanagerapplet
    brightnessctl
    zsh
    cargo
    unzip
    intel-media-driver
  ];

  hardware.pixelbook-go-audio = {
    enable = true;
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
      wqy_zenhei
      wqy_microhei
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
    printing.enable = true;
    logind = {
      settings.Login.HandlePowerKey = "ignore";
    };
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
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiJmOfDs7q5HatKbKa5G5c/cfBE3NlTUikLVzGa125n hjzhang216@gmail.com"
    ];
  };

}
