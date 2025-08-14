{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home-manager.dwm;

  configPath = ../templates/dwm-config/${cfg.configName}.h;
  hasConfigFile = builtins.pathExists configPath;

  customDwm = pkgs.dwm.overrideAttrs (oldAttrs: {
    __intentionallyOverridingVersion = true;
    version = oldAttrs.version + "-custom";
    postPatch = (oldAttrs.postPatch or "") + ''
      cp ${configPath} config.h
      touch config.h
    '';
  });

  # 自定义的 graphical-session.target（允许手动启动）
  # 覆盖系统的 graphical-session.target，以便在非 NixOS 系统上手动启动
  graphicalSessionTarget = pkgs.writeText "graphical-session.target" ''
    [Unit]
    Description=Home Manager Graphical Session
    Documentation=man:systemd.special(7)
    Requires=basic.target
    After=graphical-session-pre.target basic.target
  '';

  # dwm 启动脚本
  dwmStartScript = pkgs.writeShellScriptBin "dwm-start" ''
    # Java 应用环境变量（解决 dwm 中 Java 应用显示问题）
    export _JAVA_AWT_WM_NONREPARENTING=1

    # 推送环境变量到 systemd 用户会话
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

    # 重新加载 systemd 配置
    systemctl --user daemon-reload

    # 开启图形会话 target，触发 home-manager 的 systemd 服务
    systemctl --user start graphical-session.target

    # 启动 dwm
    exec ${if hasConfigFile then customDwm else pkgs.dwm}/bin/dwm
  '';
in
{
  options = {
    home-manager.dwm = {
      enable = mkEnableOption "Enable dwm with an optional custom config.h";

      configName = mkOption {
        type = types.str;
        default = "default";
        description = ''
          The name of the configuration file to use from modules/templates/dwm-config/.
          If the file doesn't exist, dwm is used without replacement.
        '';
        example = "pixelbook";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (if hasConfigFile then customDwm else pkgs.dwm)
      dwmStartScript
    ];

    # 安装自定义的 graphical-session.target
    # 覆盖系统的 graphical-session.target，允许手动启动
    xdg.configFile."systemd/user/graphical-session.target".source = graphicalSessionTarget;
  };
}

