# deploy-rs node definitions.
{
  hosts,
  self,
  deploy-rs,
}: let
  deployableHosts =
    builtins.filter (
      host:
        host.nixos
        && host ? ip
        && (host.deploy or false)
        && builtins.hasAttr host.hostname self.nixosConfigurations
    )
    hosts;
in {
  deploy = {
    nodes = builtins.listToAttrs (
      map (host: {
        name = host.hostname;
        value = {
          hostname = host.ip;
          sshUser = "root";
          sshOptions =
            if host ? sshPort
            then ["-p" (toString host.sshPort)]
            else [];
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${host.hostname};
          };
        };
      })
      deployableHosts
    );
  };
}
