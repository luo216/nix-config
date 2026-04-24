{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customYazi;
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

      settings = {
        mgr = {
          show_hidden = false;
          show_symlink = true;
        };

        preview = {
          max_width = 600;
          max_height = 900;
        };
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
              name = "*/";
              fg = "blue";
              bold = true;
            }
          ];
        };

        icons = {
          "Desktop/" = "";
          "Documents/" = "";
          "Downloads/" = "";
          "Pictures/" = "";
          "Music/" = "";
          "Movies/" = "";
          "Videos/" = "";
          "Public/" = "";
          "Library/" = "";
          "Development/" = "";
          ".config/" = "";
          ".git/" = "";
          ".gitignore" = "";
          ".gitmodules" = "";
          ".gitattributes" = "";
          ".DS_Store" = "";
          ".bashrc" = "";
          ".bashprofile" = "";
          ".zshrc" = "";
          ".zshenv" = "";
          ".zprofile" = "";
          ".vimrc" = "";
          "*.txt" = "";
          "*.md" = "";
          "*.zip" = "";
          "*.tar" = "";
          "*.gz" = "";
          "*.7z" = "";
          "*.mp3" = "";
          "*.flac" = "";
          "*.wav" = "";
          "*.mp4" = "";
          "*.mkv" = "";
          "*.avi" = "";
          "*.mov" = "";
          "*.jpg" = "";
          "*.jpeg" = "";
          "*.png" = "";
          "*.gif" = "";
          "*.webp" = "";
          "*.avif" = "";
          "*.bmp" = "";
          "*.ico" = "";
          "*.svg" = "";
          "*.c" = "";
          "*.cpp" = "";
          "*.h" = "";
          "*.hpp" = "";
          "*.rs" = "";
          "*.go" = "";
          "*.py" = "";
          "*.js" = "";
          "*.ts" = "";
          "*.tsx" = "";
          "*.jsx" = "";
          "*.rb" = "";
          "*.php" = "";
          "*.java" = "";
          "*.sh" = "";
          "*.fish" = "";
          "*.swift" = "";
          "*.vim" = "";
          "*.lua" = "";
          "*.html" = "";
          "*.css" = "";
          "*.scss" = "";
          "*.json" = "";
          "*.toml" = "";
          "*.yml" = "";
          "*.yaml" = "";
          "*.ini" = "";
          "*.conf" = "";
          "*" = "";
          "*/" = "";
        };
      };
    };
  };
}

