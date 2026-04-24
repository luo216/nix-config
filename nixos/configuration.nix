# Shared NixOS configuration applied to all hosts
{
  config,
  inputs,
  outputs,
  lib,
  host,
  ...
}:

let
  homeManagerUsers = builtins.listToAttrs (
    map (user: {
      name = user.username;
      value = {
        _module.args = {
          inherit user;
          homeConfigurationName = "${user.username}@${host.hostname}";
          integratedHomeManager = true;
        };
        imports = [ (../home-manager + "/${host.hostname}/${user.username}") ];
      };
    }) host.users
  );

in
{
  imports = [
    ./disko/${host.hostname}.nix
    ./config/${host.hostname}/default.nix
    inputs.stylix.nixosModules.stylix
  ] ++ lib.optionals (host.withHomeManager or false) [
    inputs.home-manager.nixosModules.home-manager
  ];

  # ── Facter ────────────────────────────────────────────
  facter.reportPath = ./factors/${host.hostname}.json;

  # ── 网络 ──────────────────────────────────────────────
  networking.hostName = host.hostname;

  # ── Nixpkgs ───────────────────────────────────────────
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  # ── Nix ───────────────────────────────────────────────
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = "nix-command flakes";
        flake-registry = "";
        nix-path = config.nix.nixPath;
        trusted-users = map (user: user.username) host.users;
        substituters = [
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
      };
      channel.enable = false;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };

  # ── SSH ───────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
  ];

  # ── Home Manager ──────────────────────────────────────
  home-manager = lib.mkIf (host.withHomeManager or false) {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs host;
      integratedHomeManager = true;
    };
    users = homeManagerUsers;
  };

  system.stateVersion = "25.11";
}