{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.customFeishu;
in
{
  options.programs.customFeishu = with lib; {
    enable = mkEnableOption "Feishu (飞书) desktop app and CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.feishu # Feishu desktop (from nixpkgs-unstable)
      pkgs.feishu-cli # Feishu CLI (custom package)
    ];
  };
}
