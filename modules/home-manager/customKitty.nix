{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customKitty;
in
{
  options.programs.customKitty = {
    enable = mkEnableOption "kitty terminal";

    shell = mkOption {
      type = types.path;
      default = "${pkgs.zsh}/bin/zsh";
      defaultText = "pkgs.zsh/bin/zsh";
      description = "The shell to launch in kitty.";
    };

    themeFile = mkOption {
      type = types.str;
      default = "GruvboxMaterialDarkSoft";
      description = "The kitty theme file to use.";
    };

    fontName = mkOption {
      type = types.str;
      default = "Hack Nerd Font";
      description = "Font name to use in kitty.";
    };

    fontSize = mkOption {
      type = types.int;
      default = 18;
      description = "Font size to use in kitty.";
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      inherit (cfg) themeFile;

      font = {
        name = cfg.fontName;
        size = cfg.fontSize;
      };

      settings = {
        cursor_shape = "block";
        scrollback_lines = 10000;
        shell = cfg.shell;
        shell_integration = "enabled";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
      };

      keybindings = {
        "ctrl+shift+enter" = "launch --cwd=current";
        "ctrl+shift+\\" = "launch --location=vsplit --cwd=current";
        "ctrl+shift+n" = "new_os_window_with_cwd";
        "ctrl+shift+t" = "new_tab_with_cwd";
        "ctrl+shift+1" = "goto_tab 1";
        "ctrl+shift+2" = "goto_tab 2";
        "ctrl+shift+3" = "goto_tab 3";
        "ctrl+shift+4" = "goto_tab 4";
        "ctrl+shift+5" = "goto_tab 5";
        "ctrl+shift+6" = "goto_tab 6";
        "ctrl+shift+7" = "goto_tab 7";
        "ctrl+shift+8" = "goto_tab 8";
        "ctrl+shift+9" = "goto_tab 9";
        "ctrl+shift+f" = "toggle_layout stack";
        "ctrl+shift+left" = "neighboring_window left";
        "ctrl+shift+down" = "neighboring_window down";
        "ctrl+shift+up" = "neighboring_window up";
        "ctrl+shift+right" = "neighboring_window right";
      };
    };
  };
}
