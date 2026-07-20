# Shared Home Manager entry point applied to every managed user.
{
  host,
  inputs,
  integratedHomeManager,
  lib,
  outputs,
  user,
}: {
  imports =
    lib.optionals (!integratedHomeManager) [
      inputs.stylix.homeModules.stylix
    ]
    ++ [
      (./. + "/${host.hostname}/${user.username}")
    ];

  _module.args.user = {inherit (user) username;};

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs = lib.mkIf (!integratedHomeManager) {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
