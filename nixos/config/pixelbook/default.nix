# Pixelbook Go — Chromebook running NixOS
{
  outputs,
  pkgs,
  primaryUser,
  ...
}: {
  imports = [
    outputs.nixosModules.pixelbook-go-audio
    outputs.nixosModules.network-printers
    outputs.nixosModules.docker-easyconnect
    outputs.nixosModules.dnsmasq-dhcp
    outputs.nixosModules.ventoy-insecure
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    plymouth.enable = true;
    initrd.systemd.enable = true;
    kernelModules = ["i2c-dev"];
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    resumeDevice = "/dev/mmcblk0p2";
  };

  powerManagement.enable = true;

  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    useDHCP = false;
    dhcpcd.enable = false;
  };

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

  hardware = {
    pixelbook-go-audio = {
      enable = true;
      driver = "avs";
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  };

  security = {
    pki.certificateFiles = [
      ../../../modules/templates/certs/mitmproxy-ca-cert.pem
    ];
    wrappers.sparkle = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin,cap_net_raw+ep";
      source = "${pkgs.sparkle}/bin/sparkle";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      sparkle
      vim
      wget
      curl
      rsync
      networkmanager
      brightnessctl
      zsh
      unzip
      bubblewrap
      intel-media-driver
      ventoy
      scrcpy
      tigervnc
      cisco-packettracer
    ];
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      LIBVA_DRIVERS_PATH = "/run/current-system/sw/lib/dri";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/bin/bwrap - - - - ${pkgs.bubblewrap}/bin/bwrap"
  ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-han-sans
      source-han-serif
      source-han-mono
      noto-fonts-color-emoji
    ];
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif CJK SC"
          "Source Han Serif SC"
          "Noto Serif"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "Source Han Sans SC"
          "Noto Sans"
          "Noto Color Emoji"
        ];
        monospace = [
          "Source Han Mono SC"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono"
          "Noto Color Emoji"
        ];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    adb.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
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
        lcms2
        libpng
        libjpeg_turbo
        expat
        harfbuzz
        graphite2
        pixman
        nspr
        nss
        sqlite
        libnotify
        icu
        libva
      ];
    };
  };

  services = {
    dbus.enable = true;
    udisks2.enable = true;
    libinput.enable = false;
    gnome.gnome-remote-desktop.enable = true;
    logind.settings.Login.HandlePowerKey = "ignore";
    todesk.enable = true;
    desktopManager.gnome.enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      defaultSession = "gnome";
      autoLogin = {
        enable = true;
        user = primaryUser;
      };
    };
    printing = {
      enable = true;
      drivers = with pkgs; [brlaser];
    };
    network-printers = {
      enable = true;
      printers = [
        {
          name = "pantum-m6760";
          description = "Pantum M6760";
          location = "Wi-Fi Direct";
          deviceUri = "ipp://192.168.223.1/ipp/print";
          model = "everywhere";
          testHosts = ["192.168.223.1"];
          ppdOptions = {
            PageSize = "A4";
            Duplex = "None";
          };
        }
      ];
    };
    docker-easyconnect = {
      enable = false;
      socksPort = 1080;
      httpPort = 8888;
      vncPort = 5901;
      mode = "proxy";
      vncPassword = "passwd";
    };
    dnsmasq-dhcp = {
      enable = false;
      interface = "enp0s20f0u2u4c2";
      subnet = "192.168.99";
      hostIP = 1;
      poolStart = 100;
      poolEnd = 200;
      dns = "8.8.8.8";
      staticBindings = [];
    };
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 48;
    };
    icons = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      dark = "Adwaita";
      light = "Adwaita";
    };
    targets = {
      console.enable = true;
      gnome.enable = true;
      gtk.enable = true;
      plymouth.enable = true;
      qt.enable = true;
    };
  };
}
