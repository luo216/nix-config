# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  pkgs,
  user,
  ...
}:
{
  # Import modular configurations
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

  # Stylix theme configuration
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

  # Set your username and home directory from the flake
  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
    sessionVariables = {
      GOOGLE_CLOUD_PROJECT = "generactive-language-client";
    };
  };

  # Enable git
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
  };

  programs = {
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
  };

  services = {
    customCpa = {
      enable = true;
      apiKeys = [ "TAoAN93hhVphA6sk2Jyo7y7G" ];
      managementSecretKey = "yG9O8VX0zoJjfAKNPiGJlLrG7DdVc5-J";
    };
  };

  # User packages
  home.packages = with pkgs; [
    # === 编辑器 ===
    neovim
    vim

    # === 终端工具 ===
    # === 现代 CLI 工具 ===
    ripgrep # Better grep (rg)
    bat # Better cat with syntax highlighting
    fd # Better find
    eza # Better ls (modern replacement for exa)
    zoxide # Smart cd command
    starship # Cross-shell prompt
    fzf # Fuzzy finder
    btop # System monitor
    tree # Directory tree
    ncdu # Disk usage analyzer
    rsync
    bubblewrap # Provides bwrap sandbox helper

    # === 开发工具 ===
    lazygit # Git GUI
    git # Git with partial clone support
    gcc # C compiler
    nodejs_24 # Node.js 24
    tree-sitter # Tree-sitter CLI
    uv # Python package installer (uvx for running tools)

    # === LSP 服务器 ===
    clang-tools # clangd for C/C++
    lua-language-server
    marksman # Markdown LSP
    nil # Nix LSP
    statix # Nix 代码静态分析和格式化工具
    python3 # Python（某些插件需要）
    lua # Lua（某些插件需要）

    # === 网络工具 ===
    curl
    wget

    # === 媒体工具 ===
    ffmpeg
    mpv

    # === 图像和预览 ===
    imagemagick
    resvg
    poppler # PDF preview

    # === 数据处理 ===
    jq # JSON processor
    pandoc # Universal document converter
    markdownlint-cli2 # Markdown linting tool

    # === 压缩工具 ===
    p7zip
    unzip
    unrar

    # === 桌面应用 ===
    google-chrome-canary # Web browser
    input-leap # KVM switch (Barrier replacement)
    qq # QQ
    wechat # 微信
    wemeet # 腾讯会议
    wpsoffice-cn # WPS Office 中文版（官方）

    # === 系统工具 ===
    xdg-user-dirs
    xdg-launch
    fastfetch # System information

    # === 文件管理和文档渲染 ===
    trash-cli # 文件回收站功能
    ghostscript # PDF 渲染 (gs)
    tectonic # LaTeX 渲染（比 texlive 更轻量）
    mermaid-cli # Mermaid 图表渲染
    sqlite # SQLite3 数据库

    # === 图标主题 ===
    papirus-icon-theme

    # === 剪贴板 ===
    wl-clipboard
  ];
  programs = {
    # Enable rainbarf CPU load monitor
    customRainbarf = {
      enable = true;
      settings = {
        width = 30;
        rgb = true;
        nobattery = true;
      };
    };

    # Enable tmux terminal multiplexer
    customTmux.enable = true;

    # Enable shared fonts
    customFonts.enable = true;

    # Enable kitty terminal
    customKitty.enable = true;

    # Enable yazi file manager
    customYazi.enable = true;

    # Enable zsh shell
    customZsh.enable = true;
  };

  # kdeconnect - End-to-end encrypted file sharing and notification sync
  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };

    kdeconnect = {
      enable = true;
      indicator = true;
    };

    # Syncthing 文件同步
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      tray.enable = true;
    };
  };

  # Enable generic Linux settings for non-NixOS
  targets.genericLinux.enable = true;

  # NixGL configuration for OpenGL support
  targets.genericLinux.nixGL = {
    defaultWrapper = "mesa"; # Use mesa wrapper for Intel graphics
    installScripts = [ "mesa" ]; # Install nixGLMesa script for non-Nix packages
    vulkan.enable = true; # Enable Vulkan support
  };

  # XDG 用户目录配置 - 使用英文目录名
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
