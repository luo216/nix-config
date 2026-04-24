{
  description = "NixOS configuration deployed with deploy-rs";

  nixConfig = {
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inherit (nixpkgs) lib;

      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;

      pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };

      # ── Hosts ────────────────────────────────────────────
      hosts = [
        {
          hostname = "pixelbook";
          system = "x86_64-linux";
          deploy = true;
          withHomeManager = true;
          ip = "192.168.31.76";
          users = [{ username = "steve"; }];
        }
        {
          hostname = "hasee";
          system = "x86_64-linux";
          users = [{ username = "steve"; }];
        }
        {
          hostname = "tencent-cvm";
          system = "x86_64-linux";
          users = [{ username = "steve"; }];
        }
        {
          hostname = "pentest";
          system = "x86_64-linux";
          withHomeManager = true;
          users = [{ username = "pentest"; }];
        }
      ];

      hasNixosConfig = host: builtins.pathExists (./nixos/config + "/${host.hostname}/default.nix");
      nixosHosts = builtins.filter hasNixosConfig hosts;
      deployableHosts = builtins.filter (host: host ? ip && host ? deploy && host.deploy && hasNixosConfig host) hosts;

    in
    {
      packages = forAllSystems (system: import ./pkgs (pkgsFor system));
      formatter = forAllSystems (system: (pkgsFor system).alejandra);
      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # ── NixOS configurations ──────────────────────────────
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
        }) nixosHosts
      );

      # ── VM apps ──────────────────────────────────────────
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          mkVmApp = name: vmDrv:
            {
              "build-vm-${name}" = {
                type = "app";
                program = "${pkgs.writeShellApplication {
                  name = "build-vm-${name}";
                  runtimeInputs = with pkgs; [ coreutils gitMinimal nix ];
                  text = ''
                    set -euo pipefail
                    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
                    out_dir="''${${lib.toUpper name}_OUT_DIR:-$repo_root/out}"
                    mkdir -p "$out_dir"
                    exec nix build --out-link "$out_dir/result-vm-${name}" ".#nixosConfigurations.${name}.config.system.build.vm" "$@"
                  '';
                }}/bin/build-vm-${name}";
              };
              "vm-${name}" = {
                type = "app";
                program = "${pkgs.writeShellApplication {
                  name = "run-vm-${name}";
                  runtimeInputs = with pkgs; [ coreutils gitMinimal ];
                  text = ''
                    set -euo pipefail
                    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
                    out_dir="''${${lib.toUpper name}_OUT_DIR:-$repo_root/out}"
                    mkdir -p "$out_dir"
                    cd "$out_dir"
                    exec ${vmDrv}/bin/run-${name}-vm "$@"
                  '';
                }}/bin/run-vm-${name}";
              };
            };
        in
        mkVmApp "pentest" self.nixosConfigurations.pentest.config.system.build.vm
      );

      # ── Home Manager (standalone) ────────────────────────
      homeConfigurations = builtins.listToAttrs (
        builtins.concatLists (
          map (
            host:
            map (user: {
              name = "${user.username}@${host.hostname}";
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = pkgsFor host.system;
                extraSpecialArgs = {
                  inherit inputs outputs user host;
                  homeConfigurationName = "${user.username}@${host.hostname}";
                  integratedHomeManager = false;
                };
                modules = [ (./home-manager + "/${host.hostname}/${user.username}") ];
              };
            }) host.users
          ) hosts
        )
      );

      # ── Deploy-rs ────────────────────────────────────────
      deploy = {
        nodes = builtins.listToAttrs (
          map (host: {
            name = host.hostname;
            value = {
              hostname = host.ip;
              sshUser = "root";
              remoteBuild = false;
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${host.hostname};
              };
            };
          }) deployableHosts
        );
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}