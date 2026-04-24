{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customFonts;
in
{
  options.programs.customFonts = {
    enable = mkEnableOption "shared font packages and fontconfig defaults";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Source Han Serif SC"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans"
          "Source Han Sans SC"
          "Noto Color Emoji"
        ];
        monospace = [
          "Hack Nerd Font Mono"
          "Noto Sans Mono"
          "Source Han Mono SC"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    home.packages = with pkgs; [
      corefonts
      noto-fonts-color-emoji
      noto-fonts
      source-han-sans
      source-han-serif
      source-han-mono
      nerd-fonts.hack
      liberation_ttf
      carlito
      caladea
    ];
  };
}
