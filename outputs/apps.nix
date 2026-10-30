# Convenience apps: home-manager CLI, deploy-rs CLI, and nixos-anywhere installer.
{
  forAllSystems,
  inputs,
  nixpkgs,
  self,
}: let
  inherit (inputs) home-manager deploy-rs;
  hosts = import ./hosts.nix;

  # `nix run .#install -- <hostname>` — full nixos-anywhere install of any
  # NixOS host in hosts.nix. Zero external network dependency: the kexec
  # tarball is uploaded from the local artifact and the closure is built
  # locally, then both are pushed over SSH.
  # Rebuild the tarball with:
  #   nix build github:nix-community/nixos-images#packages.x86_64-linux.kexec-installer-nixos-unstable-noninteractive
  #   cp result/nixos-kexec-installer-*.tar.gz artifacts/
  installApp = system: let
    pkgs = nixpkgs.legacyPackages.${system};
    kexecTarball = self + "/artifacts/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz";
    # NixOS hosts only; host.ip is an ssh-config alias, so ports resolve
    # from ~/.ssh/config (nixos-anywhere's --ssh-port flags stay as fallback
    # overrides, defaulting to 22 for direct LAN hosts).
    installable = builtins.filter (host: host.nixos or false) hosts;
    caseFor = host: let
      port = host.sshPort or 22;
    in ''
      ${host.hostname})
        exec ${pkgs.nixos-anywhere}/bin/nixos-anywhere \
          --flake ${self}#${host.hostname} \
          --target-host root@${host.ip} \
          --ssh-port ${toString port} \
          --post-kexec-ssh-port ${toString port} \
          --kexec ${kexecTarball} \
          "''${@:2}"
        ;;
    '';
    usage = "usage: install <" + builtins.concatStringsSep "|" (map (h: h.hostname) installable) + "> [nixos-anywhere options...]";
  in
    pkgs.writeShellScript "install" ''
      if [ $# -lt 1 ]; then
        echo "${usage}" >&2
        exit 1
      fi
      case "$1" in
      ${builtins.concatStringsSep "      " (map caseFor installable)}      *)
        echo "unknown host '$1' (or host is not nixos=true in outputs/hosts.nix)" >&2
        echo "${usage}" >&2
        exit 1
        ;;
      esac
    '';
in {
  apps = forAllSystems (system: {
    home-manager = {
      type = "app";
      program = "${home-manager.packages.${system}.default}/bin/home-manager";
      meta.description = "Run the Home Manager CLI pinned by this flake";
    };
    deploy = {
      type = "app";
      program = "${deploy-rs.packages.${system}.default}/bin/deploy";
      meta.description = "Run deploy-rs for the deployment nodes defined by this flake";
    };
    install = {
      type = "app";
      program = "${installApp system}";
      meta.description = "nixos-anywhere full install of a hosts.nix host: install <hostname> [extra options]";
    };
  });
}
