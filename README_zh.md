# 模块化 NixOS 配置

一个使用 Nix Flakes 构建的模块化、可扩展的 NixOS 配置系统。

## ✨ 特性

- **🦾 硬件自动检测:** 使用 `nixos-facter` 生成特定于硬件的配置。
- **💾 声明式磁盘分区:** 使用 `disko` 对磁盘布局进行声明式管理。
- **🚀 远程部署:** 支持使用 `nixos-anywhere` 进行远程安装，并使用 `deploy-rs` 进行更新。
- **🧩 模块化设计:** 结构清晰，为 NixOS 和 Home Manager 提供了可复用的模块。
- **🖥️ 预配置模块:** 包含 `dwm`, `rofi`, `fcitx5`, `yazi` 等即用型模块。

## 📁 目录结构

```
.
├── flake.nix
├── home-manager
│   ├── hasee
│   │   └── steve
│   ├── pixelbook
│   │   └── steve
│   └── sec-lab
│       └── sec
├── modules
│   ├── home-manager
│   ├── nixos
│   └── templates
├── nixos
│   ├── config
│   │   ├── pixelbook
│   │   └── sec-lab
│   ├── configuration.nix
│   ├── disko
│   └── factors
├── overlays
└── pkgs
```

## 🚀 快速上手

### 1. 定义新主机

在 `flake.nix` 的 `hosts` 列表中添加你的新设备。

```nix
# flake.nix
hosts = [
  {
    hostname = "your-hostname";
    system = "x86_64-linux";
    deploy = true; # 可选：将此主机纳入 deploy-rs
    withHomeManager = true; # 可选：在 NixOS 构建时集成 Home Manager
    ip = "192.168.1.100"; # 用于 deploy-rs
    users = [ { username = "your-user"; } ];
  }
];
```

主机级开关说明：

- `deploy = true`：把该主机加入 `deploy.nodes`，供 `deploy-rs` 使用
- `withHomeManager = true`：在 NixOS 构建时，把该主机下所有用户集成到 `home-manager.users`

Home Manager 命名规则：

- 独立 Home Manager 输出使用 `user@host`，例如 `steve@pixelbook`
- NixOS 集成的 Home Manager 内部仍然使用真实用户名，例如 `home-manager.users.steve`
- 这样同一台主机既可以单独更新 Home Manager，也可以在 NixOS 更新时一并更新

公共 Home Manager 基础模块：

- `modules/home-manager/base.nix` 提供用户配置共享的 Home Manager 公共默认层
- 它统一处理 `nix.gc`、`programs.home-manager.enable`，以及独立 HM 与集成 HM 下的 `nixpkgs` 兼容逻辑
- 新增用户配置时，一般先导入 `outputs.homeManagerModules.base`，再叠加主机或用户自己的模块

### 2. 配置磁盘布局

在 `nixos/disko/your-hostname.nix` 中为新主机创建一个磁盘布局。

```nix
# nixos/disko/your-hostname.nix
{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda"; # 修改为你的磁盘设备
      content = {
        type = "gpt";
        partitions = {
          ESP = { size = "512M"; type = "EF00"; content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }; };
          root = { size = "100%"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; }; };
        };
      };
    };
  };
}
```

### 3. 添加主机和用户配置

为新主机和用户创建必要的目录和配置文件。你可以从结构接近的现有主机目录复制并修改。

- **NixOS 配置:** `nixos/config/your-hostname/`
- **Home Manager 配置:** `home-manager/your-hostname/your-user/`

### 4. 安装 NixOS

使用 `nixos-anywhere` 在目标设备上安装 NixOS。该命令会自动检测硬件、生成配置文件并安装系统。

**⚠️ 这是一个破坏性操作，将会清除目标磁盘上的所有数据。 ⚠️**

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#your-hostname \
  --target-host root@<target-ip>
```

### 5. 部署配置

安装完成后，你可以使用 `deploy-rs` 来管理和部署更新。

```bash
# 部署主机变更
nix run github:serokell/deploy-rs -- .#your-hostname
```

对于用户特定的设置，直接在目标设备上使用 Home Manager 应用。

```bash
# 在目标设备上执行
home-manager switch --flake .#your-user@your-hostname
```

NixOS 主机补充说明：

- 如果设置了 `withHomeManager = true`，那么 `nixos-rebuild` 和 `deploy-rs` 会在更新系统时一并更新该主机集成的 Home Manager 配置
- 同时你仍然可以使用 `homeConfigurations."your-user@your-hostname"` 这种独立输出做仅用户层更新
- 在 `pixelbook` 上，Stylix 现在由 system 级配置统一管理，用户 Home Manager 不再单独定义 Stylix

## 🐧 在 Non-NixOS 系统上使用 Home Manager

如果你想在 Arch Linux、Ubuntu、Fedora 等 Non-NixOS 系统上使用 Home Manager 管理用户配置，请按照以下步骤操作：

### 1. 安装 Nix

使用官方安装脚本安装 Nix：

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

安装完成后，你需要重新打开终端或者执行：

```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### 2. 配置 Flakes 和 Trusted User

启用 Flakes 功能并设置当前用户为 trusted user（这样才能使用 flake.nix 中配置的缓存服务器）：

```bash
# 创建用户级配置目录
mkdir -p ~/.config/nix

# 启用 Flakes 实验性功能（用户级）
cat >> ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF

# 设置当前用户为 trusted user（需要 sudo，系统级配置）
sudo bash -c 'echo "trusted-users = steve" >> /etc/nix/nix.conf'

# 启用自动优化 Nix store（节省磁盘空间）
sudo bash -c 'echo "auto-optimise-store = true" >> /etc/nix/nix.conf'

# 重启 nix-daemon 服务
sudo systemctl restart nix-daemon
```

**关于 auto-optimise-store：**
- 该选项会自动检测 Nix store 中的重复文件，并通过硬链接消除重复
- 通常能节省 20-40% 的磁盘空间
- 在每次构建后自动执行，无需手动干预
- 对用户和程序完全透明，不影响正常使用

### 3. 安装 Home Manager

使用 Flakes 安装 Home Manager：

```bash
nix run home-manager/master -- switch --flake .#your-user@your-hostname
```

例如，对于 hasee 主机的 steve 用户：

```bash
nix run home-manager/master -- switch --flake .#steve@hasee
```

### 4. 应用配置

后续更新配置时，只需运行：

```bash
home-manager switch --flake .#your-user@your-hostname
```

### 注意事项

- 在 Non-NixOS 系统上，你只能使用 Home Manager 管理用户环境，无法使用 NixOS 系统级配置
- Home Manager 会自动安装必要的依赖，但某些系统级功能可能需要手动配置
- 配置中的 `targets.genericLinux.enable = true` 已启用，可以提供更好的 Linux 兼容性
