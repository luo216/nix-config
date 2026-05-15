{
  self,
  nixpkgs,
  home-manager,
  disko,
  nixos-facter-modules,
  NixVirt,
  deploy-rs,
  ...
}@inputs:
let
  inherit (self) outputs;
  lib = import ./lib.nix { inherit nixpkgs; };
  hosts = import ./hosts.nix;
in
builtins.foldl' (a: b: a // b) { } [
  (import ./packages.nix { inherit (lib) forAllSystems pkgsFor; })
  (import ./modules.nix { inherit inputs; })
  (import ./nixos-configs.nix {
    inherit nixpkgs hosts inputs outputs disko nixos-facter-modules NixVirt;
  })
  (import ./home-configs.nix {
    inherit hosts inputs outputs home-manager;
    inherit (lib) pkgsFor;
  })
  (import ./apps.nix {
    inherit self inputs;
    inherit (lib) forAllSystems pkgsFor;
  })
  (import ./deploy.nix { inherit hosts self inputs deploy-rs; })
]
