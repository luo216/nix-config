{
  config,
  inputs,
  lib,
  outputs,
  integratedHomeManager ? false,
  ...
}:

let
  cfg = config.customBase;
in
{
  imports = lib.optionals (!integratedHomeManager) [
    inputs.stylix.homeModules.stylix
  ];

  options.customBase = {
    enableLocalNixpkgs = lib.mkOption {
      type = lib.types.bool;
      default = !integratedHomeManager;
      description = "Whether this Home Manager profile should manage its own nixpkgs settings.";
    };
  };

  config = lib.mkMerge [
    {
      nix.gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "daily";
        options = lib.mkDefault "--delete-older-than 7d";
      };

      programs.home-manager.enable = lib.mkDefault true;
    }

    (lib.mkIf cfg.enableLocalNixpkgs {
      nixpkgs = {
        overlays = [
          outputs.overlays.additions
          outputs.overlays.unstable-packages
        ];
        config.allowUnfree = true;
      };
    })
  ];
}
