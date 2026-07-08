{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customYazi;
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
    }) textExtensions;
in
{
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
            on = [ "<C-g>" ];
            run = "shell 'lazygit' --block --confirm";
            desc = "Open lazygit in current directory";
          }
        ];
      };

      theme = {
        mgr = {
          cwd = {
            fg = "cyan";
          };
          hovered = {
            fg = "black";
            bg = "lightblue";
          };
          preview_hovered = {
            underline = true;
          };
          find_keyword = {
            fg = "yellow";
            italic = true;
          };
          find_position = {
            fg = "magenta";
            bg = "reset";
            italic = true;
          };
          marker_selected = {
            fg = "lightgreen";
            bg = "lightgreen";
          };
          marker_copied = {
            fg = "lightyellow";
            bg = "lightyellow";
          };
          marker_cut = {
            fg = "lightred";
            bg = "lightred";
          };
          tab_active = {
            fg = "black";
            bg = "lightblue";
          };
          tab_inactive = {
            fg = "white";
            bg = "darkgray";
          };
          tab_width = 1;
          border_symbol = " ";
          folder_offset = [
            1
            0
            1
            0
          ];
          preview_offset = [
            1
            1
            1
            1
          ];
          syntect_theme = "";
        };

        status = {
          separator_open = "";
          separator_close = "";
          separator_style = {
            fg = "darkgray";
            bg = "darkgray";
          };
          mode_normal = {
            fg = "black";
            bg = "lightblue";
            bold = true;
          };
          mode_select = {
            fg = "black";
            bg = "lightgreen";
            bold = true;
          };
          mode_unset = {
            fg = "black";
            bg = "lightmagenta";
            bold = true;
          };
          progress_label = {
            bold = true;
          };
          progress_normal = {
            fg = "blue";
            bg = "black";
          };
          progress_error = {
            fg = "red";
            bg = "black";
          };
          permissions_t = {
            fg = "lightgreen";
          };
          permissions_r = {
            fg = "lightyellow";
          };
          permissions_w = {
            fg = "lightred";
          };
          permissions_x = {
            fg = "lightcyan";
          };
          permissions_s = {
            fg = "darkgray";
          };
        };

        select = {
          border = {
            fg = "blue";
          };
          active = {
            fg = "magenta";
          };
          inactive = { };
        };

        input = {
          border = {
            fg = "blue";
          };
          title = { };
          value = { };
          selected = {
            reversed = true;
          };
        };

        completion = {
          border = {
            fg = "blue";
          };
          active = {
            bg = "darkgray";
          };
          inactive = { };
          icon_file = "";
          icon_folder = "";
          icon_command = "";
        };

        tasks = {
          border = {
            fg = "blue";
          };
          title = { };
          hovered = {
            underline = true;
          };
        };

        which = {
          mask = {
            bg = "black";
          };
          cand = {
            fg = "lightcyan";
          };
          rest = {
            fg = "darkgray";
          };
          desc = {
            fg = "magenta";
          };
          separator = "  ";
          separator_style = {
            fg = "darkgray";
          };
        };

        help = {
          on = {
            fg = "magenta";
          };
          exec = {
            fg = "cyan";
          };
          desc = {
            fg = "gray";
          };
          hovered = {
            bg = "darkgray";
            bold = true;
          };
          footer = {
            fg = "black";
            bg = "white";
          };
        };

        filetype = {
          rules = [
            {
              mime = "image/*";
              fg = "cyan";
              bold = true;
            }
            {
              mime = "video/*";
              fg = "yellow";
              bold = true;
            }
            {
              mime = "audio/*";
              fg = "yellow";
              bold = true;
            }
            {
              mime = "application/zip";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/gzip";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/x-tar";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/x-bzip";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/x-bzip2";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/x-7z-compressed";
              fg = "magenta";
              bold = true;
            }
            {
              mime = "application/x-rar";
              fg = "magenta";
              bold = true;
            }
            {
              url = "*/";
              fg = "blue";
              bold = true;
            }
          ];
        };

        icon = {
          prepend_dirs = [
            { name = "Desktop"; text = ""; }
            { name = "Documents"; text = ""; }
            { name = "Downloads"; text = ""; }
            { name = "Pictures"; text = ""; }
            { name = "Music"; text = ""; }
            { name = "Movies"; text = ""; }
            { name = "Videos"; text = ""; }
            { name = "Public"; text = ""; }
            { name = "Library"; text = ""; }
            { name = "Development"; text = ""; }
            { name = ".config"; text = ""; }
            { name = ".git"; text = ""; }
          ];
          prepend_files = [
            { name = ".gitignore"; text = ""; }
            { name = ".gitmodules"; text = ""; }
            { name = ".gitattributes"; text = ""; }
            { name = ".DS_Store"; text = ""; }
            { name = ".bashrc"; text = ""; }
            { name = ".bashprofile"; text = ""; }
            { name = ".zshrc"; text = ""; }
            { name = ".zshenv"; text = ""; }
            { name = ".zprofile"; text = ""; }
            { name = ".vimrc"; text = ""; }
          ];
          prepend_exts = [
            { name = "txt"; text = ""; }
            { name = "md"; text = ""; }
            { name = "zip"; text = ""; }
            { name = "tar"; text = ""; }
            { name = "gz"; text = ""; }
            { name = "7z"; text = ""; }
            { name = "mp3"; text = ""; }
            { name = "flac"; text = ""; }
            { name = "wav"; text = ""; }
            { name = "mp4"; text = ""; }
            { name = "mkv"; text = ""; }
            { name = "avi"; text = ""; }
            { name = "mov"; text = ""; }
            { name = "jpg"; text = ""; }
            { name = "jpeg"; text = ""; }
            { name = "png"; text = ""; }
            { name = "gif"; text = ""; }
            { name = "webp"; text = ""; }
            { name = "avif"; text = ""; }
            { name = "bmp"; text = ""; }
            { name = "ico"; text = ""; }
            { name = "svg"; text = ""; }
            { name = "c"; text = ""; }
            { name = "cpp"; text = ""; }
            { name = "h"; text = ""; }
            { name = "hpp"; text = ""; }
            { name = "rs"; text = ""; }
            { name = "go"; text = ""; }
            { name = "py"; text = ""; }
            { name = "js"; text = ""; }
            { name = "ts"; text = ""; }
            { name = "tsx"; text = ""; }
            { name = "jsx"; text = ""; }
            { name = "rb"; text = ""; }
            { name = "php"; text = ""; }
            { name = "java"; text = ""; }
            { name = "sh"; text = ""; }
            { name = "fish"; text = ""; }
            { name = "swift"; text = ""; }
            { name = "vim"; text = ""; }
            { name = "lua"; text = ""; }
            { name = "html"; text = ""; }
            { name = "css"; text = ""; }
            { name = "scss"; text = ""; }
            { name = "json"; text = ""; }
            { name = "toml"; text = ""; }
            { name = "yml"; text = ""; }
            { name = "yaml"; text = ""; }
            { name = "ini"; text = ""; }
            { name = "conf"; text = ""; }
          ];
        };
      };
    };
  };
}
