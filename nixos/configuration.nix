# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  host,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    # Import the disko configuration for the current host
    ./disko/${host.hostname}.nix
    # Import host-specific configuration
    ./config/${host.hostname}/default.nix
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.dwm
    outputs.nixosModules.pixelbook-go-audio
    # Stylix theme system
    inputs.stylix.nixosModules.stylix

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  # Configure facter to use the report for the current host
  facter.reportPath = ./factors/${host.hostname}.json;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;

        # Give users in this list the right to specify additional substituters via:
        #    1. `nixConfig.substituters` in `flake.nix`
        #    2. command line args `--options substituters http://xxx`
        trusted-users = map (user: user.username) host.users;

        # Cache server configuration
        substituters = [
          # cache mirror located in China
          # status: https://mirror.sjtu.edu.cn/
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          # status: https://mirrors.ustc.edu.cn/status/
          # "https://mirrors.ustc.edu.cn/nix-channels/store"

          "https://cache.nixos.org"
        ];

        trusted-public-keys = [
          # SJTU mirror public key (same as cache.nixos.org)
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Set your hostname from the flake
  networking.hostName = host.hostname;

  # Configure root user for deploy-rs
  users.users.root = {
    # Set initial password for root user
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiJmOfDs7q5HatKbKa5G5c/cfBE3NlTUikLVzGa125n hjzhang216@gmail.com"
    ];
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login for deploy-rs (you can change this to "prohibit-password" if using keys)
      PermitRootLogin = "yes";
      # Use keys only for security
      PasswordAuthentication = false;
    };
  };

  # Ensure zsh is fully configured when used as a login shell
  programs.zsh.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
