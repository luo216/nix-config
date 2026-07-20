# Shared helpers used by multiple output modules.
{nixpkgs}: let
  inherit (nixpkgs) lib;

  systems = ["x86_64-linux"];
in {
  inherit systems;
  forAllSystems = lib.genAttrs systems;
  pkgsFor = system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
}
