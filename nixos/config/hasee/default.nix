# Hasee — Intel/NVIDIA laptop migrated from Arch Linux
{
  outputs,
  pkgs,
  primaryUser,
  ...
}: let
  nvidiaPrimeEnv = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
in {
  imports = [
    outputs.nixosModules.docker-easyconnect
    outputs.nixosModules.dnsmasq-dhcp
    outputs.nixosModules.nps-ehang
    outputs.nixosModules.ventoy-insecure
    outputs.nixosModules.wine-gui-tools
    outputs.nixosModules.virtualizationHost
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    plymouth.enable = true;
    initrd = {
      systemd.enable = true;
      kernelModules = [
        "i915"
        "vfio"
        "vfio_pci"
      ];
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "intel_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "vfio-pci.ids=15b7:5002"
    ];
    kernelModules = [
      "kvm-intel"
      "vfio"
      "vfio_pci"
      # services.xserver remains disabled for the Wayland-only desktop, so load
      # the NVIDIA DRM stack explicitly instead of relying on the X11 module.
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
    ];
    blacklistedKernelModules = ["nouveau"];
    extraModprobeConfig = ''
      options hid_apple fnmode=2 swap_fn_leftctrl=1 swap_opt_cmd=1
      options vfio-pci ids=15b7:5002
      options kvm ignore_msrs=1
      softdep nvme pre: vfio-pci
    '';
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/9647d1d7-540b-4fdf-ac99-61f64ae84568";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
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
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    uinput.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    nvidia = {
      open = true;
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  };

  security = {
    sudo.wheelNeedsPassword = false;
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
      libva-utils
      pciutils
      usbutils
      qemu_kvm
      OVMFFull
      swtpm
      acpica-tools
      virt-viewer
      virtio-win
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
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = nvidiaPrimeEnv;
      };
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
    thermald.enable = true;
    dbus.enable = true;
    udisks2.enable = true;
    fstrim.enable = true;
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
    xserver = {
      enable = false;
      videoDrivers = ["nvidia"];
    };
    switcherooControl.enable = true;
    fwupd.enable = true;
    sunshine = {
      enable = true;
      package = pkgs.sunshine;
      openFirewall = true;
      capSysAdmin = true;
    };
    docker-easyconnect = {
      enable = true;
      socksPort = 1080;
      httpPort = 8888;
      vncPort = 5901;
      mode = "proxy";
      vncPassword = "passwd";
    };
    dnsmasq-dhcp = {
      enable = false;
      interface = "enp3s0";
      subnet = "192.168.99";
      hostIP = 1;
      poolStart = 100;
      poolEnd = 200;
      dns = "8.8.8.8";
      staticBindings = [];
    };
    nps-ehang = {
      enable = true;
      webIp = "127.0.0.1";
      webPort = 18080;
      bridgePort = 18024;
      adminPassword = "passwd";
      allowPorts = ["20000-20100"];
    };
    virtualizationHost.enable = true;
    wine-gui-tools.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
    };
    oci-containers = {
      backend = "docker";
      containers.pairdrop = {
        image = "lscr.io/linuxserver/pairdrop:latest";
        autoStart = true;
        ports = ["0.0.0.0:8090:3000"];
        environment = {
          PUID = "1000";
          PGID = "100";
          WS_FALLBACK = "true";
          RATE_LIMIT = "false";
          RTC_CONFIG = "false";
          DEBUG_MODE = "false";
          TZ = "Asia/Shanghai";
        };
      };
    };
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
