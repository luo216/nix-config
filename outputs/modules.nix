# Overlays and reusable NixOS / home-manager modules.
{inputs}: {
  overlays = import ../overlays {inherit inputs;};
  nixosModules = import ../modules/nixos;
  homeManagerModules = import ../modules/home-manager;
}
