# deploy-rs node definitions and deployment checks.
{
  hosts,
  self,
  inputs,
  deploy-rs,
}:
let
  hasConfig = host: builtins.pathExists (../nixos/config + "/${host.hostname}/default.nix");
  deployableHosts = builtins.filter (host: host ? ip && host ? deploy && host.deploy && hasConfig host) hosts;
in
{
  deploy = {
    nodes = builtins.listToAttrs (
      map (host: {
        name = host.hostname;
        value = {
          hostname = host.ip;
          sshUser = "root";
          sshOptions = if host ? sshPort then [ "-p" (toString host.sshPort) ] else [ ];
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${host.hostname};
          };
        };
      }) deployableHosts
    );
  };

  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
