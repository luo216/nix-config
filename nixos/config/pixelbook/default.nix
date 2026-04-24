# Pixelbook Go — Chromebook 刷 NixOS
{ pkgs, outputs, ... }:

{
  imports = [
    outputs.nixosModules.pixelbook-go-audio
    outputs.nixosModules.network-printers
    outputs.nixosModules.docker-easyconnect
  ];

  # ── 引导 ──────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };
    plymouth.enable = true;
    kernelModules = [ "i2c-dev" ];
    initrd.systemd.enable = true;
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

  # ── 电源管理 ──────────────────────────────────────────
  powerManagement.enable = true;

  # ── 网络 ──────────────────────────────────────────────
  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    useDHCP = false;
    dhcpcd.enable = false;
  };

  # ventoy 标记为 insecure，放行后可安装；版本更新无漏洞后删除此行
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];

  # ── 时区与语言 ────────────────────────────────────────
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

  # ── 硬件 ──────────────────────────────────────────────
  hardware = {
    pixelbook-go-audio.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  };

  # ── 用户 ──────────────────────────────────────────────
  users.users.steve = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "video"
      "adbusers"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
    ];
  };

  # ── 安全 ──────────────────────────────────────────────
  security.wrappers.sparkle = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    source = "${pkgs.sparkle}/bin/sparkle";
  };

  # ── 系统包 ────────────────────────────────────────────
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
    ];

    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      LIBVA_DRIVERS_PATH = "/run/current-system/sw/lib/dri";
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/bin/bwrap - - - - ${pkgs.bubblewrap}/bin/bwrap"
  ];

  # ── 字体 ──────────────────────────────────────────────
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

  # ── 程序 ──────────────────────────────────────────────
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
        libpng
        libjpeg_turbo
        sqlite
        libnotify
        icu
        libva
      ];
    };
  };

  # ── 服务 ──────────────────────────────────────────────
  services = {
    dbus.enable = true;
    udisks2.enable = true;

    printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
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
          testHosts = [ "192.168.223.1" ];
          ppdOptions = {
            PageSize = "A4";
            Duplex = "None";
          };
        }
      ];
    };

    gnome.gnome-remote-desktop.enable = true;
    logind.settings.Login.HandlePowerKey = "ignore";

    desktopManager.gnome.enable = true;

    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      defaultSession = "gnome";
      autoLogin = {
        enable = true;
        user = "steve";
      };
    };

    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        tapping = false;
        clickMethod = "clickfinger";
      };
    };

    docker-easyconnect = {
      enable = false;
      socksPort = 1080;
      httpPort = 8888;
      vncPort = 5901;
      mode = "proxy";
      vncPassword = "change-me";
    };
  };

  # ── 虚拟化 ────────────────────────────────────────────
  virtualisation.docker.enable = true;

  # ── 主题 ──────────────────────────────────────────────
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
