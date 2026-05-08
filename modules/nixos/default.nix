# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  docker-easyconnect = import ./docker-easyconnect.nix;
  dnsmasq-dhcp = import ./dnsmasq-dhcp.nix;
  network-printers = import ./network-printers.nix;
  pixelbook-go-audio = import ./pixelbook-go-audio.nix;
  win11-vm = import ./win11-vm.nix;
}
