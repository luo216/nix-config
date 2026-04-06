{
  config,
  lib,
  outputs,
  integratedHomeManager ? false,
  ...
}:

with lib;

let
  cfg = config.homeManagerBase;
in
{
  options.homeManagerBase = {
    enableLocalNixpkgs = mkOption {
      type = types.bool;
      default = !integratedHomeManager;
      description = "Whether this Home Manager profile should manage its own nixpkgs settings.";
    };
  };

  config = mkMerge [
    {
      nix.gc = {
        automatic = mkDefault true;
        dates = mkDefault "daily";
        options = mkDefault "--delete-older-than 7d";
      };

      programs.home-manager.enable = mkDefault true;
    }

    (mkIf cfg.enableLocalNixpkgs {
      nixpkgs = {
        overlays = [
          outputs.overlays.additions
          outputs.overlays.modifications
          outputs.overlays.unstable-packages
        ];
        config.allowUnfree = true;
      };
    })
  ];
}
