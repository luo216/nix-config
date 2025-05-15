{ config, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    wqy_zenhei
    nerd-fonts.hack
  ];

  home.file.".local/share/fonts/nix" = {
    source =
      let
        fontsDrv = pkgs.buildEnv {
          name = "nix-fonts";
          paths = config.home.packages;
          pathsToLink = [ "/share/fonts" ];
        };
      in "${fontsDrv}/share/fonts";
    recursive = true;
  };
}
