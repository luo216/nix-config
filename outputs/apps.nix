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
          };
        };
    in
    {
      home-manager = {
        type = "app";
        program = "${hm}/bin/home-manager";
      };
      deploy = {
        type = "app";
        program = "${deploy}/bin/deploy";
      };
    } // mkVmApp "pentest" self.nixosConfigurations.pentest.config.system.build.vm
  );
}
