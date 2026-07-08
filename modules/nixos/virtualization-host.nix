{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.virtualizationHost;
in {
  options.services.virtualizationHost.enable =
    lib.mkEnableOption "libvirt + virt-manager host setup";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    programs.virt-manager.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
