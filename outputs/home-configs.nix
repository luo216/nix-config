# Standalone Home Manager configurations — <user>@<host> per host.
{
  hosts,
  inputs,
  outputs,
  pkgsFor,
  home-manager,
}:
{
  homeConfigurations = builtins.listToAttrs (
    builtins.concatLists (
      map (
        host:
        map (user: {
          name = "${user.username}@${host.hostname}";
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor host.system;
            extraSpecialArgs = {
              inherit inputs outputs user host;
              homeConfigurationName = "${user.username}@${host.hostname}";
              integratedHomeManager = false;
            };
            modules = [ (../home-manager + "/${host.hostname}/${user.username}") ];
          };
        }) host.users
      ) hosts
    )
  );
}
