{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.wine-gui-tools;
in {
  options.services.wine-gui-tools = {
    enable = lib.mkEnableOption "Wine runtime for Windows GUI tools";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wineWowPackages.stableFull;
      defaultText = lib.literalExpression "pkgs.wineWowPackages.stableFull";
      description = ''
        Wine package used to run Windows GUI tools. The default keeps both
        32-bit and 64-bit support and enables the broader compatibility set.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.winetricks
    ];

    fonts.packages = with pkgs; [
      corefonts
      vista-fonts
      vista-fonts-chs
    ];
  };
}
