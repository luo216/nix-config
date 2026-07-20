# Standalone Home Manager configurations — <user>@<host> per host.
{
  hosts,
  inputs,
  lib,
  outputs,
  pkgsFor,
  home-manager,
}: let
  standaloneHosts = builtins.filter (host: !(host.withHomeManager or false)) hosts;

  hasHome = host: username: let
    homeFile = "home-manager/${host.hostname}/${username}/default.nix";
  in
    if builtins.pathExists (../. + "/${homeFile}")
    then true
    else throw "missing Home Manager user ${username}@${host.hostname}; create:\n  - ${homeFile}";
in {
  homeConfigurations = builtins.listToAttrs (
    builtins.concatLists (
      map (
        host:
          map (
            username: {
              name = "${username}@${host.hostname}";
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = pkgsFor host.system;
                extraSpecialArgs = {
                  user = {inherit username;};
                  inherit inputs outputs host;
                  integratedHomeManager = false;
                };
                modules = [
                  (import ../home-manager/configuration.nix {
                    inherit inputs lib outputs host;
                    user = {inherit username;};
                    integratedHomeManager = false;
                  })
                ];
              };
            }
          )
          (builtins.filter (hasHome host) host.users)
      )
      standaloneHosts
    )
  );
}
