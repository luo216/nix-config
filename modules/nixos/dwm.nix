{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.xserver.windowManager.mydwm;

  configPath = ../../modules/templates/dwm-config/${cfg.configName}.h;
  hasConfigFile = builtins.pathExists configPath;

  customDwm = pkgs.dwm.overrideAttrs (oldAttrs: {
    __intentionallyOverridingVersion = true;
    version = oldAttrs.version + "-custom";
    postPatch = ''
      cp ${configPath} config.h
      touch config.h
    '';
  });

in
{

  ###### interface

  options = {
    services.xserver.windowManager.mydwm = {
      enable = mkEnableOption "mydwm";

      useCustomConfig = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use custom configuration from templates/dwm-config/.
          If false, uses the default dwm configuration.
        '';
      };

      configName = mkOption {
        type = types.str;
        default = "default";
        description = ''
          The name of the configuration file to use from modules/templates/dwm-config/.
          If the file doesn't exist, dwm is used without replacement.
          Only used when useCustomConfig is true.
        '';
        example = "pixelbook";
      };

      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dwm is started.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [
      (if cfg.useCustomConfig && hasConfigFile then customDwm else pkgs.dwm)
    ];

    services.xserver.windowManager.session = singleton {
      name = "mydwm";
      start = ''
        ${cfg.extraSessionCommands}

        export _JAVA_AWT_WM_NONREPARENTING=1
        ${if cfg.useCustomConfig && hasConfigFile then customDwm else pkgs.dwm}/bin/dwm &
        waitPID=$!
      '';
    };

  };

}
