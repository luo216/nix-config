{
  outputs,
  pkgs,
  user,
  ...
}: {
  imports = [
    outputs.homeManagerModules.customTmux
    outputs.homeManagerModules.customRainbarf
    outputs.homeManagerModules.customZsh
    outputs.homeManagerModules.customFonts
  ];

  targets.genericLinux.enable = true;

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
    sessionVariables = {
      GOOGLE_CLOUD_PROJECT = "generactive-language-client";
    };

    packages = with pkgs; [
      neovim
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
      lazygit
      gh
      nodejs_24
      tree-sitter
      uv
      clang-tools
      lua-language-server
      marksman
      nil
      statix
      python3
      lua
      httpie
      mkcert
      nssTools
      ffmpeg
      imagemagick
      resvg
      poppler-utils
      file
      jq
      markdownlint-cli2
      p7zip
      unrar
      cc-switch-cli
      fastfetch
      trash-cli
      sqlite
      xclip
    ];
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "test";
          email = "pentest@example.com";
        };
      };
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
    customZsh.enable = true;

    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings.mgr = {
        show_hidden = false;
        show_symlink = true;
      };
    };
  };
}
