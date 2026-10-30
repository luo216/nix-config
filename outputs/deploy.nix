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
          # host.ip is an ssh-config alias; the SSH port lives in
          # ~/.ssh/config because deploy-rs's nix copy stage ignores
          # sshOptions and would hit port 22 on the raw address.
          hostname = host.ip;
          sshUser = "root";
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
