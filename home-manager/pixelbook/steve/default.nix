# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  inputs,
  pkgs,
  user,
  ...
}:
{
  # Import modular configurations
  imports = [
    inputs.stylix.homeModules.stylix # Stylix theme system
    outputs.homeManagerModules.dunst # Notification daemon (dunst)
    outputs.homeManagerModules.rainbarf # CPU load monitor (rainbarf)
    outputs.homeManagerModules.tmux # Terminal multiplexer (tmux)
    outputs.homeManagerModules.rofi # Application launcher (rofi)
    outputs.homeManagerModules.fcitx5 # Chinese input method (fcitx5)
    outputs.homeManagerModules.customYazi # File manager (yazi)
    outputs.homeManagerModules.customZsh # Shell (zsh)
    outputs.homeManagerModules.templates # Template files mapping
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
      qt.enable = true;
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Nix 垃圾回收配置
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
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

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      settings = {
        user = {
          name = "hjzhang";
          email = "hjzhang216@gmail.com";
        };
      };
    };
  };

  # Enable fontconfig to discover fonts from home.packages
  fonts.fontconfig.enable = true;

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
    # Rofi application launcher
    rofi = {
      enable = true;
      theme = "gruvbox-material"; # Use the custom theme from templates
      font = "Hack Nerd Font 16";
      terminal = "kitty";
      iconTheme = "Papirus-Dark";
    };

    # Fcitx5 Chinese input method
    fcitx5 = {
      enable = true;
      theme = "gruvbox-material";
    };
  };

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    themeFile = "GruvboxMaterialDarkSoft";
    font = {
      name = "Hack Nerd Font";
      size = 18;
    };
    settings = {
      # Cursor and display
      cursor_shape = "block";
      scrollback_lines = 10000;

      # Shell configuration
      shell = "${pkgs.zsh}/bin/zsh";

      # Font rendering
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
    };
  };

  # User packages
  home.packages = with pkgs; [
    # === 编辑器 ===
    neovim
    vim

    # === 终端工具 ===
    kitty

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
    gcc # C compiler
    gnumake # Build automation tool
    nodejs_24 # Node.js 24
    yarn # Node.js package manager
    tree-sitter # Tree-sitter CLI

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
    feh

    # === 数据处理 ===
    jq # JSON processor
    pandoc # Universal document converter
    markdownlint-cli2 # Markdown linting tool

    # === 压缩工具 ===
    p7zip

    # === 桌面应用 ===
    rofi # Application launcher
    flameshot # Screenshot tool
    arandr # Display settings
    networkmanagerapplet
    input-leap # KVM switch (Barrier replacement)
    rustdesk # Remote desktop
    moonlight-qt # Video player
    google-chrome # Web browser
    wpsoffice-cn # WPS Office 中国版
    qq # QQ
    wechat # 微信
    wemeet # 腾讯会议

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

    # === 字体 - 覆盖 WPS 需求 ===
    # 微软
    corefonts # 包含常用微软字体 (Arial, Times New Roman, 等)
    vista-fonts # 包含 Calibri, Cambria 等 Vista 字体

    # Windows 标准英文字体
    liberation_ttf # Liberation 系列 (Times, Arial, Courier 的开源替代)
    dejavu_fonts # DejaVu 字体家族

    # 符号字体
    stix-otf # STIX 字体 (学术出版标准，包含 Symbol)
    symbola # Unicode 符号字体

    # Wingdings 替代
    dejavu_fonts # DejaVu 包含类似的符号字体

    # 中文字体 - 适合正式文档
    source-han-sans # 思源黑体 (Adobe + Google)
    source-han-serif # 思源宋体 (Adobe + Google)

    # 等宽字体 - 代码和公式
    jetbrains-mono # 现代等宽字体

    # === 剪贴板 ===
    xclip
    wl-clipboard

    # === 文件管理器 ===
    xfce.thunar
  ];

  # udiskie - U 盘自动挂载服务
  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
      settings = {
        program_options = {
          # 设置文件管理器，挂载后自动打开
          file_manager = "${pkgs.xfce.thunar}/bin/thunar";
        };
      };
    };

    # polkit-gnome - PolicyKit 认证代理
    polkit-gnome.enable = true;

    # kdeconnect - End-to-end encrypted file sharing and notification sync
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

  # Enable dunst notification daemon
  programs = {
    dunst.enable = true;

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

    # Enable yazi file manager
    customYazi.enable = true;

    # Enable zsh shell
    customZsh.enable = true;
  };

  # Template files mapping
  home-manager.templates = {
    enable = true;
    mappings = [
      {
        source = "wallpaper/default.png";
        target = ".local/share/wallpaper/default.png";
      }
      {
        source = "scripts";
        target = ".local/bin";
        recursive = true;
      }
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
