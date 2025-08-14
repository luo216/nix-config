{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home-manager.fcitx5;

in
{
  options = {
    home-manager.fcitx5 = {
      enable = mkEnableOption "Enable Fcitx5 Chinese input method";

      theme = mkOption {
        type = types.str;
        default = "gruvbox-material";
        description = "Fcitx5 theme to use";
        example = "macOS-dark";
      };
    };
  };

  config = mkIf cfg.enable {
    # Configure fcitx5 input method
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          qt6Packages.fcitx5-chinese-addons # Chinese input support
          qt6Packages.fcitx5-configtool # Configuration tool
          fcitx5-gtk # GTK integration
          fcitx5-pinyin-zhwiki # Chinese Wikipedia dictionary
        ];

        settings = {
          # Global hotkey settings
          globalOptions = {
            "Hotkey/TriggerKeys" = {
              "0" = "Shift_R"; # Right Shift to toggle input method
            };
          };

          # Input method configuration
          inputMethod = {
            # Group configuration
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "keyboard-us"; # Default to English
            };

            # Input method items
            "Groups/0/Items/0" = {
              "Name" = "keyboard-us"; # English keyboard
              "Layout" = "";
            };
            "Groups/0/Items/1" = {
              "Name" = "pinyin"; # Chinese pinyin input
              "Layout" = "";
            };

            # Group order
            "GroupOrder" = {
              "0" = "Default";
            };
          };

          # Addon configurations
          addons = {
            # Classic UI configuration
            classicui.globalSection = {
              # Theme settings
              "Theme" = cfg.theme;
              "DarkTheme" = cfg.theme;
              "UseDarkTheme" = "False";
              "UseAccentColor" = "True";

              # Layout and display
              "Vertical Candidate List" = "False";
              "WheelForPaging" = "True";
              "PreferTextIcon" = "False";
              "ShowLayoutNameInIcon" = "True";
              "UseInputMethodLanguageToDisplayText" = "True";

              # Font settings
              "Font" = "Sans Serif 18";
              "MenuFont" = "Sans Serif 12";
              "TrayFont" = "Sans Bold 10";

              # Tray colors
              "TrayOutlineColor" = "#000000";
              "TrayTextColor" = "#ffffff";

              # DPI and scaling
              "PerScreenDPI" = "False";
              "ForceWaylandDPI" = "0";
              "EnableFractionalScale" = "True";
            };

            # Pinyin settings
            pinyin.globalSection = {
              "PageSize" = 9;
              "CloudPinyinEnabled" = "True";
              "CloudPinyinIndex" = 2;
            };

            # Cloud pinyin backend
            cloudpinyin.globalSection = {
              "Backend" = "Baidu";
            };
          };
        };

      };
    };

    # Copy custom theme files
    home.file.".local/share/fcitx5/themes/${cfg.theme}" = {
      source = ../templates/fcitx5-themes/${cfg.theme};
      recursive = true;
    };

  };
}
