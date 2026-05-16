# Convenience apps: home-manager CLI, deploy-rs CLI, and VM run/build scripts.
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
      inherit (pkgs) lib;

      mkVmApp = name: vmDrv:
        {
          "build-vm-${name}" = {
            type = "app";
            program = "${pkgs.writeShellApplication {
              name = "build-vm-${name}";
              runtimeInputs = with pkgs; [ coreutils gitMinimal nix ];
              text = ''
                set -euo pipefail
                repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
                out_dir="''${${lib.toUpper name}_OUT_DIR:-$repo_root/out}"
                mkdir -p "$out_dir"
                exec nix build --out-link "$out_dir/result-vm-${name}" ".#nixosConfigurations.${name}.config.system.build.vm" "$@"
              '';
            }}/bin/build-vm-${name}";
            meta.description = "Build the ${name} NixOS VM and link it under ./out";
          };
          "vm-${name}" = {
            type = "app";
            program = "${pkgs.writeShellApplication {
              name = "run-vm-${name}";
              runtimeInputs = with pkgs; [ coreutils gitMinimal ];
              text = ''
                set -euo pipefail
                repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
                out_dir="''${${lib.toUpper name}_OUT_DIR:-$repo_root/out}"
                mkdir -p "$out_dir"
                cd "$out_dir"
                exec ${vmDrv}/bin/run-${name}-vm "$@"
              '';
            }}/bin/run-vm-${name}";
            meta.description = "Run the ${name} NixOS VM from the local ./out workspace";
          };
        };
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
    } // mkVmApp "pentest" self.nixosConfigurations.pentest.config.system.build.vm
      // {
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
