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
          "Times New Roman"
          "SimSun"
          "宋体"
          "Source Han Serif SC"
          "Noto Serif"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Source Han Sans SC"
          "Noto Sans"
          "Noto Color Emoji"
        ];
        monospace = [
          "Hack Nerd Font"
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
