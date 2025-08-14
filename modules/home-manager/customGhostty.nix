{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.customGhostty;
in {
  options.programs.customGhostty = {
    enable = mkEnableOption "Ghostty terminal";

    shell = mkOption {
      type = types.path;
      default = "${pkgs.zsh}/bin/zsh";
      defaultText = "pkgs.zsh/bin/zsh";
      description = "The shell to launch in Ghostty.";
    };

    theme = mkOption {
      type = types.str;
      default = "Gruvbox Material Dark";
      description = "The Ghostty built-in theme to use.";
    };

    fontName = mkOption {
      type = types.str;
      default = "Hack Nerd Font";
      description = "Font name to use in Ghostty.";
    };

    fontSize = mkOption {
      type = types.int;
      default = 18;
      description = "Font size to use in Ghostty.";
    };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableBashIntegration = false;

      settings = {
        # 字体
        font-family = cfg.fontName;
        font-size = cfg.fontSize;

        # 主题与外观
        inherit (cfg) theme;
        cursor-style = "block";
        window-padding-x = 4;
        window-padding-y = 4;

        # 滚动
        scrollback-limit = 10000;

        # Shell
        command = cfg.shell;
        shell-integration = "zsh";

        # ===== 快捷键 =====

        # --- 分屏操作 (ctrl+alt) ---
        keybind = [
          # 新建分屏
          "ctrl+alt+minus=new_split:down"
          "ctrl+alt+backslash=new_split:right"
          # 切换分屏焦点（方向键）
          "ctrl+alt+left=goto_split:left"
          "ctrl+alt+down=goto_split:down"
          "ctrl+alt+up=goto_split:up"
          "ctrl+alt+right=goto_split:right"
          # 切换分屏焦点（vim 风格）
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+j=goto_split:down"
          "ctrl+alt+k=goto_split:up"
          "ctrl+alt+l=goto_split:right"
          # 当前分屏全屏/还原
          "ctrl+alt+enter=toggle_split_zoom"
          # 关闭当前分屏
          "ctrl+alt+w=close_surface"

          # --- Tab 操作 (ctrl+shift) ---
          "ctrl+shift+t=new_tab"
          "ctrl+shift+w=close_tab"
          "ctrl+shift+left=previous_tab"
          "ctrl+shift+right=next_tab"
          # goto_tab 1-9
          "ctrl+shift+1=goto_tab:1"
          "ctrl+shift+2=goto_tab:2"
          "ctrl+shift+3=goto_tab:3"
          "ctrl+shift+4=goto_tab:4"
          "ctrl+shift+5=goto_tab:5"
          "ctrl+shift+6=goto_tab:6"
          "ctrl+shift+7=goto_tab:7"
          "ctrl+shift+8=goto_tab:8"
          "ctrl+shift+9=goto_tab:9"

          # --- 窗口操作 ---
          "ctrl+shift+n=new_window"
          "ctrl+shift+q=quit"

          # --- 字体缩放 ---
          "ctrl+equal=increase_font_size:1"
          "ctrl+minus=decrease_font_size:1"
          "ctrl+zero=reset_font_size"
        ];
      };
    };
  };
}
