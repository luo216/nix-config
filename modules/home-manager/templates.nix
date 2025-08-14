{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.home-manager.templates;

  # Function to create file mappings from templates directory
  createFileMappings =
    mappings:
    lib.listToAttrs (
      map (
        mapping:
        if mapping.recursive then
          {
            name = mapping.target;
            value = {
              source = ../templates + "/${mapping.source}";
              recursive = true;
            };
          }
        else
          {
            name = mapping.target;
            value = {
              source = ../templates + "/${mapping.source}";
            };
          }
      ) mappings
    );

in
{
  options = {
    home-manager.templates = {
      enable = mkEnableOption "Enable template files mapping";

      mappings = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              source = mkOption {
                type = types.str;
                description = "Source path relative to modules/templates directory";
                example = "rofi-themes/macos/rounded-nord-dark.rasi";
              };

              target = mkOption {
                type = types.str;
                description = "Target path in home directory (relative to home)";
                example = ".config/rofi/themes/custom.rasi";
              };

              recursive = mkOption {
                type = types.bool;
                default = false;
                description = "Recursively copy directories";
              };
            };
          }
        );
        default = [ ];
        description = ''
          List of file/directory mappings from templates directory to home directory.
          Source paths are relative to modules/templates directory.
          Target paths are relative to the user's home directory.
        '';
        example = literalExpression ''
          [
            # Single file mapping
            {
              source = "wallpaper/default.png";
              target = ".config/wallpaper.png";
            }
            # Recursive directory mapping
            {
              source = "rofi-themes/macos";
              target = ".config/rofi/themes";
              recursive = true;
            }
            # Another single file
            {
              source = "tmux/tmux.conf";
              target = ".config/tmux/tmux.conf";
            }
          ]
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.file = createFileMappings cfg.mappings;
  };
}
