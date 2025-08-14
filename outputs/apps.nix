# Convenience apps: home-manager CLI and deploy-rs CLI.
{
  forAllSystems,
  inputs,
}: let
  inherit (inputs) home-manager deploy-rs;
in {
  apps = forAllSystems (
    system: let
      hm = home-manager.packages.${system}.default;
      deploy = deploy-rs.packages.${system}.default;
    in {
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
    }
  );
}
