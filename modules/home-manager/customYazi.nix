{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.customYazi;
  gruvboxDark = pkgs.fetchzip {
    url = "https://codeload.github.com/bennyyip/gruvbox-dark.yazi/tar.gz/619fdc5844db0c04f6115a62cf218e707de2821e";
    hash = "sha256-Y/i+eS04T2+Sg/Z7/CGbuQHo5jxewXIgORTQm25uQb4=";
    extension = "tar.gz";
  };
  textExtensions = [
    "*.md"
    "*.txt"
    "*.nix"
    "*.toml"
    "*.yaml"
    "*.yml"
    "*.json"
    "*.jsonc"
    "*.ini"
    "*.conf"
    "*.cfg"
    "*.sh"
    "*.bash"
    "*.zsh"
    "*.fish"
    "*.lua"
    "*.py"
    "*.js"
    "*.jsx"
    "*.ts"
    "*.tsx"
    "*.rs"
    "*.c"
    "*.h"
    "*.cpp"
    "*.hpp"
    "*.go"
    "*.java"
    "*.css"
    "*.scss"
    "*.html"
    "*.sql"
    "*.csv"
    "*.lock"
  ];
  textOpenRules =
    [
      {
        mime = "text/*";
        use = [
          "edit"
          "open"
        ];
      }
    ]
    ++ map (pattern: {
      url = pattern;
      use = [
        "edit"
        "open"
      ];
    })
    textExtensions;
in {
  options.programs.customYazi = {
    enable = mkEnableOption "yazi file manager";

    package = mkOption {
      type = types.package;
      default = pkgs.unstable.yazi;
      defaultText = "pkgs.unstable.yazi";
      description = "The yazi package to use.";
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      inherit (cfg) package;
      extraPackages = with pkgs; [
        file
        loupe
        mpv
        neovim
        xdg-utils
      ];

      settings = {
        mgr = {
          show_hidden = false;
          show_symlink = true;
        };

        preview = {
          max_width = 600;
          max_height = 900;
        };

        opener = {
          edit = [
            {
              run = "nvim %s";
              block = true;
              desc = "Neovim";
              for = "unix";
            }
          ];
          play = [
            {
              run = "mpv %s";
              orphan = true;
              desc = "mpv";
              for = "unix";
            }
          ];
          image = [
            {
              run = "loupe %s";
              orphan = true;
              desc = "Loupe";
              for = "unix";
            }
          ];
          open = [
            {
              run = "xdg-open %s1";
              orphan = true;
              desc = "System default";
              for = "unix";
            }
          ];
        };

        open.prepend_rules =
          [
            {
              mime = "video/*";
              use = [
                "play"
                "open"
              ];
            }
            {
              mime = "audio/*";
              use = [
                "play"
                "open"
              ];
            }
            {
              mime = "image/*";
              use = [
                "image"
                "open"
              ];
            }
          ]
          ++ textOpenRules;
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["<C-g>"];
            run = "shell 'lazygit' --block --confirm";
            desc = "Open lazygit in current directory";
          }
        ];
      };

      flavors.gruvbox-dark = gruvboxDark;

      theme = {
        flavor = {
          dark = "gruvbox-dark";
          light = "gruvbox-dark";
        };

        icon = {
          prepend_conds = [
            {
              "if" = "dir & hovered";
              text = "";
              fg = "#fabd2f";
            }
            {
              "if" = "dir";
              text = "";
              fg = "#fabd2f";
            }
          ];
          prepend_dirs = map (icon: icon // { fg = "#fabd2f"; }) [
            {
              name = "Desktop";
              text = "";
            }
            {
              name = "Documents";
              text = "";
            }
            {
              name = "Downloads";
              text = "";
            }
            {
              name = "Pictures";
              text = "";
            }
            {
              name = "Music";
              text = "";
            }
            {
              name = "Movies";
              text = "";
            }
            {
              name = "Videos";
              text = "";
            }
            {
              name = "Public";
              text = "";
            }
            {
              name = "Library";
              text = "";
            }
            {
              name = "Development";
              text = "";
            }
            {
              name = ".config";
              text = "";
            }
            {
              name = ".git";
              text = "";
            }
          ];
          prepend_files = [
            {
              name = ".gitignore";
              text = "";
            }
            {
              name = ".gitmodules";
              text = "";
            }
            {
              name = ".gitattributes";
              text = "";
            }
            {
              name = ".DS_Store";
              text = "";
            }
            {
              name = ".bashrc";
              text = "";
            }
            {
              name = ".bashprofile";
              text = "";
            }
            {
              name = ".zshrc";
              text = "";
            }
            {
              name = ".zshenv";
              text = "";
            }
            {
              name = ".zprofile";
              text = "";
            }
            {
              name = ".vimrc";
              text = "";
            }
          ];
          prepend_exts = [
            {
              name = "txt";
              text = "";
            }
            {
              name = "md";
              text = "";
            }
            {
              name = "zip";
              text = "";
            }
            {
              name = "tar";
              text = "";
            }
            {
              name = "gz";
              text = "";
            }
            {
              name = "7z";
              text = "";
            }
            {
              name = "mp3";
              text = "";
            }
            {
              name = "flac";
              text = "";
            }
            {
              name = "wav";
              text = "";
            }
            {
              name = "mp4";
              text = "";
            }
            {
              name = "mkv";
              text = "";
            }
            {
              name = "avi";
              text = "";
            }
            {
              name = "mov";
              text = "";
            }
            {
              name = "jpg";
              text = "";
            }
            {
              name = "jpeg";
              text = "";
            }
            {
              name = "png";
              text = "";
            }
            {
              name = "gif";
              text = "";
            }
            {
              name = "webp";
              text = "";
            }
            {
              name = "avif";
              text = "";
            }
            {
              name = "bmp";
              text = "";
            }
            {
              name = "ico";
              text = "";
            }
            {
              name = "svg";
              text = "";
            }
            {
              name = "c";
              text = "";
            }
            {
              name = "cpp";
              text = "";
            }
            {
              name = "h";
              text = "";
            }
            {
              name = "hpp";
              text = "";
            }
            {
              name = "rs";
              text = "";
            }
            {
              name = "go";
              text = "";
            }
            {
              name = "py";
              text = "";
            }
            {
              name = "js";
              text = "";
            }
            {
              name = "ts";
              text = "";
            }
            {
              name = "tsx";
              text = "";
            }
            {
              name = "jsx";
              text = "";
            }
            {
              name = "rb";
              text = "";
            }
            {
              name = "php";
              text = "";
            }
            {
              name = "java";
              text = "";
            }
            {
              name = "sh";
              text = "";
            }
            {
              name = "fish";
              text = "";
            }
            {
              name = "swift";
              text = "";
            }
            {
              name = "vim";
              text = "";
            }
            {
              name = "lua";
              text = "";
            }
            {
              name = "html";
              text = "";
            }
            {
              name = "css";
              text = "";
            }
            {
              name = "scss";
              text = "";
            }
            {
              name = "json";
              text = "";
            }
            {
              name = "toml";
              text = "";
            }
            {
              name = "yml";
              text = "";
            }
            {
              name = "yaml";
              text = "";
            }
            {
              name = "ini";
              text = "";
            }
            {
              name = "conf";
              text = "";
            }
          ];
        };
      };
    };
  };
}
