{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.customRainbarf;
in {
  options.programs.customRainbarf = {
    enable = mkEnableOption "rainbarf CPU load monitor for tmux";

    package = mkOption {
      type = types.package;
      default = pkgs.perlPackages.Apprainbarf;
      defaultText = "pkgs.perlPackages.Apprainbarf";
      description = "The rainbarf package to use.";
    };

    settings = mkOption {
      type = with types;
        attrsOf (oneOf [
          bool
          str
          int
        ]);
      default = {};
      description = "Configuration for rainbarf.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."rainbarf/rainbarf.conf".text = let
      formatSetting = name: value:
        if builtins.isBool value
        then
          (
            if value
            then name
            else "no${name}"
          )
        else "${name}=${toString value}";
    in
      concatStringsSep "\n" (mapAttrsToList formatSetting cfg.settings);
  };
}
