{
  description = "A NixOS configuration that can be deployed with deploy-rs";

  nixConfig = {
    # override the default substituters
    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"

      # nix community's cache server
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      # SJTU mirror public key (same as cache.nixos.org)
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Stylix
    stylix.url = "github:danth/stylix/release-25.11";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Facter
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    # Deploy-rs
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      stylix,
      disko,
      nixos-facter-modules,
      deploy-rs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Generate attributes for each system
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Hosts and users configuration
      hosts = [
        {
          hostname = "pixelbook";
          system = "x86_64-linux";
          ip = "192.168.31.76";
          users = [
            {
              username = "steve";
              # user-specific attributes can go here
            }
          ];
        }
        {
          hostname = "hasee";
          system = "x86_64-linux";
          users = [
            {
              username = "steve";
              # user-specific attributes can go here
            }
          ];
        }
        {
          hostname = "vm-test";
          system = "x86_64-linux";
          ip = "192.168.122.76";
          users = [
            {
              username = "steve";
              # user-specific attributes can go here
            }
          ];
        }
      ];

    in
    {
      # Custom packages
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # Formatter for Nix files
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Overlays
      overlays = import ./overlays { inherit inputs; };

      # Reusable nixos modules
      nixosModules = import ./modules/nixos;

      # Reusable home-manager modules
      homeManagerModules = import ./modules/home-manager;

      # NixOS configurations for hosts with IP (deploy targets)
      nixosConfigurations = builtins.listToAttrs (
        map (host: {
          name = host.hostname;
          value = nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = { inherit inputs outputs host; };
            modules = [
              disko.nixosModules.disko
              nixos-facter-modules.nixosModules.facter
              ./nixos/configuration.nix
            ];
          };
        }) (builtins.filter (host: host ? ip) hosts)
      );

      # Home-manager configurations for all users
      homeConfigurations = builtins.listToAttrs (
        builtins.concatLists (
          map (
            host:
            map (user: {
              name = "${user.username}@${host.hostname}";
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.${host.system};
                extraSpecialArgs = {
                  inherit
                    inputs
                    outputs
                    user
                    host
                    ;
                };
                modules = [
                  ./home-manager/${host.hostname}/${user.username}
                ];
              };
            }) host.users
          ) hosts
        )
      );

      # Deploy-rs configuration for hosts with IP
      deploy = {
        nodes = builtins.listToAttrs (
          map (host: {
            name = host.hostname;
            value = {
              hostname = host.ip; # 远端 IP 或主机名
              sshUser = "root"; # SSH 登录用用户
              remoteBuild = false; # 强制本地构建再推送
              profiles.system = {
                user = "root"; # 系统 profile 用户
                path = deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${host.hostname};
              };
            };
          }) (builtins.filter (host: host ? ip) hosts)
        );
      };

      # Checks for deploy-rs
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
