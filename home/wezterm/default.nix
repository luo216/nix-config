{ config, pkgs, ... }:

{
  # 启用必要的字体和图形配置
  fonts.fontconfig.enable = true;

  # 安装 WezTerm 及依赖
  home.packages = with pkgs; [
    wezterm
  ];

  home.file.".config/wezterm" = {
    source = ./config;
    # copy the scripts directory recursively
    recursive = true;
  };
}
