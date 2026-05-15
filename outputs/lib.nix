# Shared helpers used by multiple output modules.
{
  nixpkgs,
}:
let
  inherit (nixpkgs) lib;

  systems = [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
in
{
  inherit systems;
  forAllSystems = lib.genAttrs systems;
  pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };
}
