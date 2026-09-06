# Claude Desktop for Linux (hasee only).
#
# The pkgs/claude-desktop-fhs package bundles everything the app needs at
# runtime inside a buildFHSEnv: the official .deb tree, MCP toolchains
# (nodejs, uv, docker), and Cowork's VM stack (qemu_kvm, OVMF shim,
# virtiofsd). What a package cannot do is touch the host — that is this
# module's job:
#
#   - put the package on the system (systemPackages), which also exposes
#     the .desktop entry and icons
#   - grant the user kvm group access so Cowork can open /dev/kvm
#   - load the vhost_vsock kernel module — Cowork's guest talks to the
#     host over vhost-vsock, and without the module coworkd aborts even
#     though a /dev/vhost-vsock node may exist
#
# Cowork additionally wants hardware virtualization enabled in the BIOS
# (outside Nix's reach) and ~25 GB free for the VM image.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.claude-desktop;
in {
  options.services.claude-desktop = {
    enable = lib.mkEnableOption "Claude Desktop (FHS wrapper incl. Cowork VM support)";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Unix user granted kvm group access for Cowork VMs.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.claude-desktop-fhs];

    # Belt and braces for /dev/kvm: on NixOS the kvm udev rule keys on
    # group membership even when the device node is world-accessible.
    users.users.${cfg.user}.extraGroups = ["kvm"];

    # Cowork boots a real accel=kvm guest whose console runs over
    # vhost-vsock; load the module at boot.
    boot.kernelModules = ["vhost_vsock"];
  };
}
