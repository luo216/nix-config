# 奎享科技写字机器人上位机软件 (kdraw) 的安装与串口权限配置。
#
# 应用是 jpackage 风格的自带 JRE 包，启动器和 jpackage 的 .cfg 里都硬编码了
# /opt/kdraw 这个绝对路径，所以本模块把包树软链到该路径，而不是改写上游文件。
# 串口侧不需要厂商驱动，也不需要自定义 udev 规则，详见下面的注释。
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.kdraw;
in {
  options.programs.kdraw = {
    enable = lib.mkEnableOption "奎享雕刻 (kdraw) 写字机器人软件";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kdraw;
      defaultText = lib.literalExpression "pkgs.kdraw";
      description = "要安装的 kdraw 包。";
    };

    installPath = lib.mkOption {
      type = lib.types.str;
      default = "/opt/kdraw";
      description = ''
        应用期望的安装路径。启动器与 jpackage 配置都以绝对路径引用该位置，
        {option}`package` 中的 opt/kdraw 树会被软链到这里。

        该路径由 systemd-tmpfiles 以符号链接方式管理，因此始终跟随
        {option}`package`，不受应用自带在线更新器影响（版本由 Nix 管理）。
      '';
    };

    serialGroup = lib.mkOption {
      type = lib.types.str;
      default = "dialout";
      description = ''
        用于串口设备访问权的组。

        这里只做校验，不创建组、也不添加成员：systemd 的
        `50-udev-default.rules` 中 `KERNEL=="tty[A-Z]*[0-9]"` 已经匹配
        `ttyUSB0`/`ttyACM0` 并置为 `dialout` 组、模式 0660，因此无需自定义
        udev 规则。用户的组成员身份应在各自的用户模块里通过
        {option}`users.users.<name>.extraGroups` 声明。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.elem cfg.serialGroup (builtins.attrNames config.users.groups);
        message = "programs.kdraw.serialGroup 指向不存在的组：${cfg.serialGroup}";
      }
    ];

    # CH340/CH341 这类 USB 转串口芯片由内核自带的 ch341 驱动处理，厂商站点上
    # 的 CH341SerSetup.exe 是 Windows 专用，Linux 上不需要也不适用。
    # udev 本来会按 modalias 自动加载，这里显式声明以免依赖该行为。
    boot.kernelModules = ["ch341"];

    environment.systemPackages = [cfg.package];

    systemd.tmpfiles.rules = [
      "L+ ${cfg.installPath} - - - - ${cfg.package}/opt/kdraw"
    ];
  };
}
