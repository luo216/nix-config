# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  docker-easyconnect = import ./docker-easyconnect.nix;
  dnsmasq-dhcp = import ./dnsmasq-dhcp.nix;
  network-printers = import ./network-printers.nix;
  nps-ehang = import ./nps-ehang.nix;
  pixelbook-go-audio = import ./pixelbook-go-audio.nix;
  wine-gui-tools = import ./wine-gui-tools.nix;
  windows-vm = import ./windows-vm.nix;
}
