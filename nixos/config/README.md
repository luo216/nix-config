# NixOS 主机配置目录

这个目录包含每个主机的专用配置，采用模块化的目录结构。

## 目录结构

每个主机都有自己的目录，包含以下模块：

```
hostname/
├── default.nix      # 主配置文件，导入所有模块
├── networking.nix   # 网络配置（防火墙、NetworkManager 等）
├── boot.nix         # 启动配置（引导加载器、内核模块等）
├── system.nix       # 系统包和服务（Nix 配置、字体、基础服务等）
├── desktop.nix      # 桌面环境配置（X11、窗口管理器、显示管理器等）
├── users.nix        # 用户配置（用户账户、SSH 密钥等）
└── locale.nix       # 本地化配置（时区、语言、控制台等）
```

## 当前主机

### pixelbook/
- **用途**: Google Pixelbook 设备
- **特色**: 
  - Pixelbook Go AVS 音频支持
  - Mihomo-party 网络代理
  - Syncthing 文件同步
  - ToDesk 远程桌面
  - 自定义触摸板配置

### hasee/
- **用途**: 神舟笔记本电脑
- **特色**: 
  - 标准笔记本配置
  - 启用触摸板轻触点击
  - 基础桌面环境

### vm-test/
- **用途**: 虚拟机测试环境
- **特色**: 
  - 最小化配置
  - 适用于测试和开发

## 添加新主机

1. 创建新的主机目录：`mkdir hostname`
2. 复制现有主机的配置文件作为模板
3. 根据新主机的需求修改各个模块
4. 在 `flake.nix` 中添加主机定义

## 模块说明

- **networking.nix**: 配置防火墙规则、网络管理器、KDE Connect 等
- **boot.nix**: 配置启动加载器、内核模块、交换分区、电源管理等
- **system.nix**: 配置 Nix 设置、系统包、字体、基础服务等
- **desktop.nix**: 配置 X11、窗口管理器、显示管理器、输入设备等
- **users.nix**: 配置用户账户、用户组、SSH 密钥等
- **locale.nix**: 配置时区、语言环境、控制台设置等
