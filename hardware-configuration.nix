# 不要修改这个文件！它是由'nixos-generate-config'自动生成的，可能会在升级时被覆盖
# 如果需要修改，请将更改复制到configuration.nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # 这是一个模板硬件配置文件
  # 在实际安装NixOS时，你需要运行'nixos-generate-config'来生成正确的硬件配置
  
  # 引导设备，需要根据你的实际硬件进行配置
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # 文件系统配置，需要根据你的实际分区进行配置
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/your-root-uuid-here";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/your-boot-uuid-here";
    fsType = "vfat";
  };

  # 交换文件配置
  swapDevices = [ ];

  # 启用所有固件
  hardware.enableRedistributableFirmware = true;

  # 高DPI显示器支持
  # hardware.video.hidpi.enable = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
} 