{ pkgs, ... }:

{
  home.packages = with pkgs; [
    audiness
  ];
}
