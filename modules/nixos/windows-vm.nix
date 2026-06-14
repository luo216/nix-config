# Windows 11 VM 宿主层:libvirtd + virt-manager。
#
# 域(win11)不再声明式托管,改由 virt-manager 手动管理,配置持久化在
# /data/vm 下。首次安装时用种子 XML 导入一次即可:
#
#     virsh -c qemu:///system define /data/vm/win11.xml
#
# 之后在 virt-manager 里改硬件(含手动直通 U 盘/USB 设备)都会持久生效。
# steve 已在 libvirtd 组,经 polkit 可无密码管理 qemu:///system。
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.windows-vm;
in {
  options.services.windows-vm.enable = lib.mkEnableOption "Windows 11 VM host (libvirt + virt-manager, NVMe passthrough)";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      # 不在开机时自动拉起标记 autostart 的域,保持手动控制。
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        # NVMe直通需要 qemu 以 root 跑以访问 vfio。
        runAsRoot = true;
        # OVMF 固件由 QEMU 自带,libvirtd 自动软链到 /run/libvirt/nix-ovmf/。
        swtpm.enable = true;
      };
    };

    # 完整 GUI 管理 + 手动 USB 直通。
    programs.virt-manager.enable = true;

    # SPICE 客户端 USB 重定向:给 spice-client-glib-usb-acl-helper 装上
    # cap_fowner setuid wrapper,否则普通用户重定向 USB 会报
    # "Error setting facl: Operation not permitted"。
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
