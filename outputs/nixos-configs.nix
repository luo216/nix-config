# NixOS system configurations — one per host with a nixos/config/<host>/default.nix.
{
  nixpkgs,
  hosts,
  inputs,
  outputs,
  disko,
  nixos-facter-modules,
  NixVirt,
}:
let
  hasConfig = host: builtins.pathExists (../nixos/config + "/${host.hostname}/default.nix");
  nixosHosts = builtins.filter hasConfig hosts;
in
{
  nixosConfigurations = builtins.listToAttrs (
    map (host: {
      name = host.hostname;
      value = nixpkgs.lib.nixosSystem {
        inherit (host) system;
        specialArgs = { inherit inputs outputs host; };
        modules = [
          disko.nixosModules.disko
          nixos-facter-modules.nixosModules.facter
          NixVirt.nixosModules.default
          ../nixos/configuration.nix
        ];
      };
    }) nixosHosts
  );
}
