# 包管理策略说明

## 概述

这个配置实现了"稳定优先，不稳定备用"的包管理策略：

- **基础**: 使用nixos-25.05稳定版本的nixpkgs
- **备用**: 当稳定版本中某个包不存在或版本太旧时，可以从nixos-unstable获取
- **配置**: 保持稳定版本的配置范式，确保兼容性

## 文件结构

```
├── flake.nix                    # 主配置文件，定义inputs和overlays
├── configuration.nix            # NixOS系统配置
├── package-overlays.nix         # 包覆盖配置（从unstable获取的包）
└── PACKAGE_MANAGEMENT.md        # 本文档
```

## 如何添加unstable包

### 1. 编辑 package-overlays.nix

在 `package-overlays.nix` 文件中添加需要的包：

```nix
final: prev: {
  # 取消注释并修改包名
  firefox = nixpkgs-unstable.legacyPackages.x86_64-linux.firefox;
  rust-analyzer = nixpkgs-unstable.legacyPackages.x86_64-linux.rust-analyzer;
}
```

### 2. 重新构建系统

```bash
# 更新flake.lock（如果需要）
nix flake update

# 重新构建系统
sudo nixos-rebuild switch --flake .#nixos
```

## 查找包版本

### 检查稳定版本中的包

```bash
# 查看稳定版本中某个包的信息
nix search nixpkgs#firefox
```

### 检查unstable版本中的包

```bash
# 查看unstable版本中某个包的信息
nix search nixpkgs#firefox --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable
```

## 最佳实践

1. **优先使用稳定版本**: 只有在必要时才从unstable获取包
2. **记录变更**: 在package-overlays.nix中添加注释说明为什么需要unstable版本
3. **定期检查**: 定期检查unstable包是否已经进入稳定版本
4. **测试**: 在应用到生产环境前测试unstable包

## 示例场景

### 场景1: 新工具只在unstable中可用

```nix
# 在package-overlays.nix中
final: prev: {
  new-tool = nixpkgs-unstable.legacyPackages.x86_64-linux.new-tool;
}
```

### 场景2: 稳定版本包太旧

```nix
# 在package-overlays.nix中
final: prev: {
  firefox = nixpkgs-unstable.legacyPackages.x86_64-linux.firefox;
}
```

### 场景3: 开发工具需要最新版本

```nix
# 在package-overlays.nix中
final: prev: {
  rust-analyzer = nixpkgs-unstable.legacyPackages.x86_64-linux.rust-analyzer;
  nodePackages.typescript-language-server = nixpkgs-unstable.legacyPackages.x86_64-linux.nodePackages.typescript-language-server;
}
```

## 注意事项

1. **依赖关系**: 从unstable获取的包可能会引入额外的依赖
2. **更新频率**: unstable包更新更频繁，可能需要更频繁地更新flake.lock
3. **稳定性**: unstable包可能不如稳定版本稳定
4. **配置兼容性**: 虽然包来自unstable，但配置仍然遵循稳定版本的范式 