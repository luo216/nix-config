{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.fcitx5-chinese-addons
        pkgs.fcitx5-configtool
        pkgs.fcitx5-pinyin-zhwiki
      ];
    };
  };

  home.file = {
    ".local/share/fcitx5/themes/macOS-dark" = {
      source = ./themes/macOS-dark;
      recursive = true;
    };
    ".config/fcitx5" = {
      source = ./config;
    };
  };

  home.sessionVariables = {
    GTK_IM_MODULE="fcitx";
    QT_IM_MODULE="fcitx";
    XMODIFIERS="@im=fcitx";
    INPUT_METHOD="fcitx";
    SDL_IM_MODULE="fcitx";
    GLFW_IM_MODULE="ibus";
    HM_TEST="hello world";
  };
}
