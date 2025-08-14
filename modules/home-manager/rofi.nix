{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home-manager.rofi;

  # Wrapper script to unset QT_PLUGIN_PATH for non-Nix Qt applications
  rofiWrapper = pkgs.writeShellScriptBin "rofi-wrapper" ''
    #!/usr/bin/env bash
    # Unset QT_PLUGIN_PATH to avoid Qt version conflicts with system Qt apps
    unset QT_PLUGIN_PATH
    exec "$@"
  '';

in
{
  options = {
    home-manager.rofi = {
      enable = mkEnableOption "Enable Rofi";

      enableWrapper = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wrapper script to unset QT_PLUGIN_PATH for non-Nix Qt applications";
      };

      theme = mkOption {
        type = types.str;
        default = "gruvbox-material";
        description = ''
          The rofi theme to use. Available themes:
          - Modern: rounded-nord-dark, rounded-blue-dark, spotlight-dark, windows11-grid-dark, squared-nord
          - Classic: Arc-Dark, gruvbox-dark, solarized, Monokai, Paper-Dark
          - Custom: gruvbox-material, onedark, fancy, material, slate
          - Or use a built-in rofi theme name
        '';
        example = "rounded-nord-dark";
      };

      font = mkOption {
        type = types.str;
        default = "Hack Nerd Font 16";
        description = "Font to use in rofi";
        example = "JetBrains Mono 14";
      };

      terminal = mkOption {
        type = types.str;
        default = "kitty";
        description = "Terminal to use for terminal applications";
        example = "alacritty";
      };

      iconTheme = mkOption {
        type = types.str;
        default = "Papirus";
        description = "Icon theme to use";
        example = "Adwaita";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        rofi
      ]
      ++ lib.optional cfg.enableWrapper rofiWrapper;

    # Copy theme files to user's config directory
    xdg.configFile."rofi/themes" = {
      source = ../templates/rofi-themes;
      recursive = true;
    };

    # Rofi configuration - migrated from example
    xdg.configFile."rofi/config.rasi".text = ''
      configuration {
        modes: [ combi, window, ssh, filebrowser ];
        combi-modes: [ drun, run ];
        show-icons: true;
        icon-theme: "${cfg.iconTheme}";
        terminal: "${cfg.terminal}";
        drun-display-format: "{name}";
        disable-history: false;
        sidebar-mode: false;
        font: "${cfg.font}";
        ${if cfg.enableWrapper then ''run-command: "${rofiWrapper}/bin/rofi-wrapper {cmd}";'' else ""}
      }

      @theme "./themes/${cfg.theme}.rasi"

      /* Custom modifications from example */
      element {
        orientation: horizontal;
        children: [ element-icon, element-text ];
        spacing: 8px;
      }

      * {
        border-radius: 10px;
      }
    '';
  };
}
