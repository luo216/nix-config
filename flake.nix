{
  description = "基本的NixOS配置";

  inputs = {
    # 稳定版本的nixpkgs (25.05)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    # unstable版本的nixpkgs (备用)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable }: {
    nixosConfigurations = {
      # 你的主机名，可以根据需要修改
      nixos = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # 添加overlay来合并两个版本的包
          {
            nixpkgs.overlays = [
              # 导入包覆盖配置
              (import ./package-overlays.nix { inherit nixpkgs-unstable; })
            ];
          }
        ];
      };
    };
  };
}
