# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  cc-switch-cli = pkgs.callPackage ./cc-switch-cli.nix { };
  cpa = pkgs.callPackage ./cpa.nix { };
  google-chrome-canary = pkgs.callPackage ./google-chrome-canary.nix { };
  wechat = pkgs.callPackage ./wechat.nix { };
}
