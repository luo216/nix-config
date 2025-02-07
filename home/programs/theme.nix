{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lxappearance
    libsForQt5.qt5ct
    # kdePackages.qtstyleplugin-kvantum
    # libsForQt5.qtstyleplugin-kvantum
  ];

  home.sessionVariables = {
      QT_QPA_PLATFORMTHEME="qt5ct";
      QT_STYLE_OVERRIDE="kvantum";
  };
}
