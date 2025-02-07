{ config, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    wqy_zenhei
    nerd-fonts.hack
  ];

  # 自动链接 Nix 安装的字体
  home.file.".local/share/fonts".source =
    let
      fontsDrv = pkgs.buildEnv {
        name = "nix-fonts";
        paths = config.home.packages;
        pathsToLink = [ "/share/fonts" ];
      };
    in "${fontsDrv}/share/fonts";
}
