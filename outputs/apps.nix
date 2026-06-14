# Convenience apps: home-manager CLI, deploy-rs CLI, and Windows VM launcher.
{
  forAllSystems,
  pkgsFor,
  self,
  inputs,
}:
let
  inherit (inputs) home-manager deploy-rs;
in
{
  apps = forAllSystems (
    system:
    let
      pkgs = pkgsFor system;
      hm = home-manager.packages.${system}.default;
      deploy = deploy-rs.packages.${system}.default;
    in
    {
      home-manager = {
        type = "app";
        program = "${hm}/bin/home-manager";
        meta.description = "Run the Home Manager CLI pinned by this flake";
      };
      deploy = {
        type = "app";
        program = "${deploy}/bin/deploy";
        meta.description = "Run deploy-rs for the deployment nodes defined by this flake";
      };
      "vm-win11" = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "win11";
          runtimeInputs = with pkgs; [ virt-viewer libvirt ];
          text = ''
            set -euo pipefail
            if ! virsh -c qemu:///system list --name | grep -qF win11; then
              echo "Starting win11..."
              virsh -c qemu:///system start win11
            fi
            exec virt-viewer -c qemu:///system win11
          '';
        }}/bin/win11";
        meta.description = "Start the Windows 11 VM and connect via SPICE";
      };
    }
  );
}
