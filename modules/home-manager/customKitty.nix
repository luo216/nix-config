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
        "ctrl+shift+enter" = "new_window_with_cwd";
        "ctrl+shift+n" = "new_os_window_with_cwd";
      };
    };
  };
}
