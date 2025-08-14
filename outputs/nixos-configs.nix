# NixOS system configurations and integrated Home Manager users.
{
  nixpkgs,
  hosts,
  inputs,
  outputs,
  disko,
  nixos-facter-modules,
}: let
  inherit (nixpkgs) lib;

  loadUser = host: username: let
    userFile = "nixos/users/${host.hostname}/${username}/default.nix";
    userPath = ../. + "/${userFile}";
    user = import userPath;
  in
    if !(user ? username)
    then throw "user configuration ${userFile} must define username"
    else if user.username != username
    then throw "user configuration ${userFile} must have username ${username}"
    else if !(user ? nixosModule)
    then throw "user ${username} must define nixosModule for host ${host.hostname}"
    else user;

  resolveHost = host: let
    nixosUsernames = host.users ++ ["root"];
    users = map (loadUser host) nixosUsernames;
    primaryUser =
      if !(host ? primaryUser)
      then throw "host ${host.hostname} must define primaryUser"
      else if !(builtins.elem host.primaryUser host.users)
      then throw "host ${host.hostname} primaryUser must be included in users"
      else host.primaryUser;

    homeManagerUser = builtins.head (builtins.filter (user: user.username == primaryUser) users);
    homeManagerUsers = {
      ${primaryUser} = {
        imports = [
          (import ../home-manager/configuration.nix {
            inherit inputs lib outputs host;
            user = homeManagerUser;
            integratedHomeManager = true;
          })
        ];
      };
    };
  in {
    inherit host users primaryUser homeManagerUsers;
  };

  expectedFiles = host:
    [
      "nixos/config/${host.hostname}/default.nix"
      "nixos/disko/${host.hostname}.nix"
      "nixos/factors/${host.hostname}.json"
    ]
    ++ map (username: "nixos/users/${host.hostname}/${username}/default.nix") (host.users ++ ["root"])
    ++ lib.optional (host.withHomeManager or false) "home-manager/${host.hostname}/${host.primaryUser}/default.nix";

  readyHost = host: let
    missing = builtins.filter (file: !(builtins.pathExists (../. + "/${file}"))) (expectedFiles host);
  in
    if missing == []
    then true
    else throw "incomplete NixOS host ${host.hostname}; create:\n  - ${builtins.concatStringsSep "\n  - " missing}";

  nixosHosts = builtins.filter readyHost (builtins.filter (host: host.nixos) hosts);
  resolvedHosts = map resolveHost nixosHosts;
in {
  nixosConfigurations = builtins.listToAttrs (
    map (
      resolved: let
        inherit (resolved) host users primaryUser homeManagerUsers;
      in {
        name = host.hostname;
        value = nixpkgs.lib.nixosSystem {
          inherit (host) system;
          specialArgs = {inherit inputs outputs host primaryUser;};
          modules =
            [
              disko.nixosModules.disko
              nixos-facter-modules.nixosModules.facter
              ../nixos/configuration.nix
              {
                nix.settings.trusted-users = builtins.filter (username: username != "root") host.users;
              }
            ]
            ++ map (user: user.nixosModule) users
            ++ lib.optionals (host.withHomeManager or false) [
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs outputs host;
                    integratedHomeManager = true;
                  };
                  users = homeManagerUsers;
                };
              }
            ];
        };
      }
    )
    resolvedHosts
  );
}
