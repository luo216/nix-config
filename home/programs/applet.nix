{ pkgs, ... }:

{
  home.packages = with pkgs; [
    networkmanagerapplet
    pasystray
  ];
}
