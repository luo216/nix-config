{
  description = "Home Manager multi-device configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
    nur.url = "github:nix-community/NUR"; # 引入 NUR
  };

  outputs = { nixpkgs, home-manager, nixgl, nur, ... }: let
    # 公共基础配置（所有设备共享）
    commonModules = [
      { nixpkgs.config.allowUnfree = true; }
      { nixpkgs.overlays = [
          (import ./overlays/dwm.nix) # 引入本地 dwm overlay
          (import ./overlays/st.nix) # 引入本地 st overlay
          nixgl.overlay # 引入 nixGL overlay
          nur.overlay # 引入 NUR overlay
        ];
      }
    ];
  in {
    homeConfigurations = {

      "pixelbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = commonModules ++ [
          ./devices/pixelbook/home.nix
        ];

        extraSpecialArgs = {
          specialArgs = {
            username = "steve";
            hostname = "pixelbook";
          };
        };
      };

      "hasee" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = commonModules ++ [
          ./devices/hasee/home.nix
        ];

        extraSpecialArgs = {
          specialArgs = {
            username = "steve";
            hostname = "hasee";
          };
        };
      };

      "vm-kali" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = commonModules ++ [
          ./devices/vm-kali/home.nix
        ];

        extraSpecialArgs = {
          specialArgs = {
            username = "kali";
            hostname = "vm-kali";
          };
        };
      };

      "vm-arch" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = commonModules ++ [
          ./devices/vm-kali/home.nix
        ];

        extraSpecialArgs = {
          specialArgs = {
            username = "steve";
            hostname = "vm-arch";
          };
        };
      };

    };
  };
}
