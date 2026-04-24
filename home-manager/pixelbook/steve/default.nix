# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  config,
  outputs,
  pkgs,
  user,
  ...
}:
let
  wallpaperUri = "file://${config.home.homeDirectory}/.local/share/wallpaper/default.png";
in
{
  # Import modular configurations
  imports = [
    outputs.homeManagerModules.base
    outputs.homeManagerModules.customFonts # Shared fonts and fontconfig
    outputs.homeManagerModules.rainbarf # CPU load monitor (rainbarf)
    outputs.homeManagerModules.tmux # Terminal multiplexer (tmux)
    outputs.homeManagerModules.customKitty # Terminal (kitty)
    outputs.homeManagerModules.fcitx5 # Chinese input method (fcitx5)
    outputs.homeManagerModules.cpa # CLI Proxy API
    outputs.homeManagerModules.customYazi # File manager (yazi)
    outputs.homeManagerModules.customZsh # Shell (zsh)
    outputs.homeManagerModules.templates # Template files mapping
  ];

  # Set your username and home directory from the flake
  home = {
    inherit (user) username;
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
      package = pkgs.adwaita-icon-theme;
      dark = "Adwaita";
      light = "Adwaita";
    };
    targets = {
      gnome.enable = true;
      gtk.enable = true;
      qt = {
        enable = true;
        platform = "qtct";
        standardDialogs = "xdgdesktopportal";
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = wallpaperUri;
      picture-uri-dark = wallpaperUri;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = false;
      natural-scroll = true;
      click-method = "fingers";
    };
    "org/gnome/shell/extensions/kimpanel" = {
      font = "Sans 16";
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "kimpanel@kde.org"
        "gsconnect@andyholmes.github.io"
        "syncthing-indicator@mkljczk.pl"
      ];
    };
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

  # Desktop applications
  home-manager = {
    # Template files mapping
    templates = {
      enable = true;
      mappings = [
        {
          source = "wallpaper/default.png";
          target = ".local/share/wallpaper/default.png";
        }
      ];
    };

    # Fcitx5 Chinese input method
    fcitx5 = {
      enable = true;
      theme = "gruvbox-material";
    };

    # CLI Proxy API
    cpa = {
      enable = true;
      apiKeys = [ "TAoAN93hhVphA6sk2Jyo7y7G" ];
      managementSecretKey = "yG9O8VX0zoJjfAKNPiGJlLrG7DdVc5-J";
    };
  };

  # User packages
  home.packages = with pkgs; [
    # === 编辑器 ===
    neovim

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

    # === 开发工具 ===
    lazygit # Git GUI
    cargo # Rust package manager and build tool
    gcc # C compiler
    gnumake # Build automation tool
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
    nuclei # Vulnerability scanner
    mitmproxy # Intercepting HTTP/HTTPS proxy
    httpie # User-friendly HTTP client
    sqlmap
    freerdp # xfreerdp CLI client for RDP

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
    unrar

    # === 桌面应用 ===
    input-leap # KVM switch (Barrier replacement)
    moonlight-qt # Video player
    google-chrome-canary # Web browser
    wpsoffice-cn # WPS Office 中文版（官方）
    qq # QQ
    wechat # 微信
    wemeet # 腾讯会议
    cc-switch-cli # Claude Code / Codex / Gemini CLI 配置切换器（CLI）

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

    # === 剪贴板 ===
    wl-clipboard
  ];
  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };

    # Syncthing 文件同步
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      tray.enable = false;
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

    # Enable rainbarf CPU load monitor
    rainbarf = {
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

    gnome-shell = {
      enable = true;
      extensions = [
        {
          package = pkgs.gnomeExtensions.appindicator;
        }
        {
          package = pkgs.gnomeExtensions.kimpanel;
        }
        {
          package = pkgs.gnomeExtensions.gsconnect;
        }
        {
          package = pkgs.gnomeExtensions.syncthing-indicator;
        }
      ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
