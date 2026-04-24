{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customTemplates;

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
    programs.customTemplates = {
      enable = mkEnableOption "Enable template files mapping";

      mappings = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              source = mkOption {
                type = types.str;
                description = "Source path relative to modules/templates directory";
                example = "wallpaper/default.png";
              };

              target = mkOption {
                type = types.str;
                description = "Target path in home directory (relative to home)";
                example = ".local/share/wallpaper/default.png";
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
