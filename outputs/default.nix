{
  self,
  nixpkgs,
  home-manager,
  disko,
  nixos-facter-modules,
  deploy-rs,
  ...
} @ inputs: let
  inherit (self) outputs;
  lib = import ./lib.nix {inherit nixpkgs;};
  hosts = import ./hosts.nix;
in
  builtins.foldl' nixpkgs.lib.recursiveUpdate {} [
    (import ./packages.nix {inherit (lib) forAllSystems pkgsFor;})
    (import ./modules.nix {inherit inputs;})
    (import ./nixos-configs.nix {
      inherit nixpkgs hosts inputs outputs disko nixos-facter-modules;
    })
    (import ./home-configs.nix {
      inherit hosts inputs outputs home-manager;
      inherit (nixpkgs) lib;
      inherit (lib) pkgsFor;
    })
    (import ./apps.nix {
      inherit inputs;
      inherit (lib) forAllSystems;
    })
    (import ./deploy.nix {inherit hosts self deploy-rs;})
  ]
