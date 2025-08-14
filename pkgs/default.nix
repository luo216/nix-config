# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  google-chrome-canary = pkgs.callPackage ./google-chrome-canary.nix { };
}
