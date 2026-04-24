{
  outputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    outputs.homeManagerModules.customBase
    outputs.homeManagerModules.customCpa # CLI Proxy API
    outputs.homeManagerModules.customTmux # Terminal multiplexer (tmux)
    outputs.homeManagerModules.customFcitx5 # Chinese input method (fcitx5)
    outputs.homeManagerModules.customRainbarf # CPU load monitor (rainbarf)
    outputs.homeManagerModules.customZsh # Shell (zsh)
    outputs.homeManagerModules.customTemplates # Template files mapping
    outputs.homeManagerModules.customYazi # File manager (yazi)
    outputs.homeManagerModules.customFonts # Shared fonts and fontconfig
    outputs.homeManagerModules.customKitty # Terminal (kitty)
  ];

  home = {
    homeDirectory = "/home/${user.username}";
    sessionVariables = {
      GOOGLE_CLOUD_PROJECT = "generactive-language-client";
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
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    targets = {
      gtk.enable = true;
      qt = {
        enable = true;
        platform = "qtct";
        standardDialogs = "xdgdesktopportal";
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };

  home.packages = with pkgs; [
    # === 编辑器 ===
    neovim

    # === 终端工具 ===
    ripgrep
    bat
    fd
    eza
    zoxide
    starship
    fzf
    btop
    tree
    ncdu

    # === 开发工具 ===
    lazygit
    cargo
    gcc
    gnumake
    nodejs_24
    tree-sitter
    uv

    # === LSP 服务器 ===
    clang-tools
    lua-language-server
    marksman
    nil
    statix
    python3
    lua

    # === 网络工具 ===
    httpie
    jq

    # === 媒体工具 ===
    ffmpeg
    mpv

    # === 图像和预览 ===
    imagemagick
    resvg
    poppler

    # === 数据处理 ===
    pandoc
    markdownlint-cli2

    # === 压缩工具 ===
    p7zip
    unrar

    # === 桌面应用 ===
    input-leap
    google-chrome-canary
    wpsoffice-cn
    qq
    wechat
    wemeet
    cc-switch-cli

    # === 系统工具 ===
    xdg-user-dirs
    xdg-launch
    fastfetch
    trash-cli
    ghostscript
    tectonic
    mermaid-cli
    sqlite
    wl-clipboard
    bubblewrap
  ];

  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };

    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      tray.enable = true;
    };

    kdeconnect = {
      enable = true;
      indicator = true;
    };

    customCpa = {
      enable = true;
      apiKeys = [ "TAoAN93hhVphA6sk2Jyo7y7G" ];
      managementSecretKey = "yG9O8VX0zoJjfAKNPiGJlLrG7DdVc5-J";
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

    customFcitx5 = {
      enable = true;
      theme = "gruvbox-material";
    };

    customTemplates = {
      enable = true;
      mappings = [
        {
          source = "wallpaper/default.png";
          target = ".local/share/wallpaper/default.png";
        }
      ];
    };

    customRainbarf = {
      enable = true;
      settings = {
        width = 30;
        rgb = true;
        nobattery = true;
      };
    };

    customTmux.enable = true;
    customFonts.enable = true;
    customKitty.enable = true;
    customYazi.enable = true;
    customZsh.enable = true;
  };

  targets.genericLinux = {
    enable = true;
    nixGL = {
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
      vulkan.enable = true;
    };
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "25.11";
}
