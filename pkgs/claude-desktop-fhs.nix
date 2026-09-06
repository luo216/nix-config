# Claude Desktop for Linux inside a buildFHSEnv.
#
# This is the package one actually installs to run Claude Desktop with
# MCP servers and Cowork on NixOS. The bare unpacked package
# (pkgs/claude-desktop.nix) only carries the app itself; it has no /usr
# layout, so MCP servers invoked by absolute FHS paths and Cowork's VM
# probes (qemu on PATH, /usr/share/OVMF, /usr/bin/virtiofsd) all miss.
# buildFHSEnv provides that /usr layout:
#   - MCP servers:  nodejs, uv (python), docker, docker-compose on PATH
#   - Cowork:       qemu_kvm (qemu-system-x86_64 on PATH), the OVMF shim
#                   (firmwarePath), virtiofsd (the second probe path)
#
# Cowork gates VM boot on BOTH a firmwarePath (the ovmfCompat shim below)
# and a qemuPath — it searches PATH for qemu-system-x86_64, and coworkd
# launches a real accel=kvm guest (pflash OVMF, vhost-vsock, virtiofsd
# --shared-dir). qemu_kvm is the host-cpu-only build, so it ships exactly
# that arch's binary. /dev/kvm and /dev/vhost-vsock are reachable inside
# the env (buildFHSEnv binds the whole /dev) but the host must still grant
# kvm-group access and load vhost_vsock — that is the claude-desktop
# NixOS module's job. --doctor flags both.
{
  lib,
  stdenv,
  runCommand,
  buildFHSEnv,
  bubblewrap,
  claude-desktop,
  docker_29,
  docker-compose,
  openssl,
  glibc,
  nodejs,
  uv,
  OVMF,
  qemu_kvm,
  virtiofsd,
}: let
  # Cowork's firmware probe list is hardcoded in the official bundle with
  # no env override:
  #   x86_64  -> /usr/share/OVMF/OVMF_CODE_4M.fd, /usr/share/OVMF/OVMF_CODE.fd
  #   aarch64 -> /usr/share/AAVMF/AAVMF_CODE.fd
  # It derives the *writable* VARS template beside the CODE file it found
  # by renaming OVMF_CODE -> OVMF_VARS, and copies it per VM to seed
  # efivars; coworkd aborts with "no EFI variable-store template
  # configured" if that sibling is absent, so the shim must expose the
  # matched CODE+VARS pair, not just CODE.
  #
  # nixpkgs' OVMF lands firmware at ${OVMF.fd}/FV/*.fd — nothing under
  # share/ — so a bare OVMF in targetPkgs never hits the probe; symlink
  # the FV/ files into share/, which buildFHSEnv maps to /usr/share.
  # The build fails loudly if a source is gone rather than ship a
  # dangling symlink that only bites at VM boot.
  ovmfCompat = let
    link = src: dst: ''
      [[ -e ${OVMF.fd}/FV/${src} ]] || {
        echo "ovmfCompat: ${OVMF.fd}/FV/${src} missing; OVMF layout changed" >&2
        exit 1
      }
      mkdir -p "$(dirname "$out/share/${dst}")"
      ln -s ${OVMF.fd}/FV/${src} "$out/share/${dst}"
    '';
    pairs = [
      (link "OVMF_CODE.fd" "OVMF/OVMF_CODE.fd")
      (link "OVMF_CODE.fd" "OVMF/OVMF_CODE_4M.fd")
      (link "OVMF_VARS.fd" "OVMF/OVMF_VARS.fd")
      (link "OVMF_VARS.fd" "OVMF/OVMF_VARS_4M.fd")
    ];
  in
    runCommand "claude-desktop-ovmf-compat" {} (lib.concatStrings pairs);
in
  buildFHSEnv {
    name = "claude-desktop";

    targetPkgs = p:
      with p; [
        bubblewrap
        claude-desktop
        docker_29
        docker-compose
        glibc
        nodejs
        openssl
        ovmfCompat
        qemu_kvm
        uv
        virtiofsd
      ];

    runScript = "${claude-desktop}/bin/claude-desktop";

    extraInstallCommands = ''
      # Copy desktop file
      mkdir -p $out/share/applications
      cp ${claude-desktop}/share/applications/* $out/share/applications/

      # Copy icons
      mkdir -p $out/share/icons
      cp -r ${claude-desktop}/share/icons/* $out/share/icons/
    '';

    meta =
      claude-desktop.meta
      // {
        description = "Claude Desktop for Linux (FHS environment for MCP servers and Cowork)";
      };
  }
