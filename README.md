# Home Manager 配置说明

<!-- vim-markdown-toc GFM -->

* [项目结构](#项目结构)
* [快速开始](#快速开始)
* [杂项](#杂项)
  * [调试阶段清理缓存](#调试阶段清理缓存)
  * [home-manager 使用教程](#home-manager-使用教程)
  * [注意](#注意)

<!-- vim-markdown-toc -->

## 项目结构
```tree
.
├── devices
│   ├── hasee
│   ├── pixelbook
│   ├── vm-arch
│   └── vm-kali
├── flake.nix
├── home
│   ├── core.nix
│   ├── programs
│   │   ├── common.nix
│   │   ├── fonts.nix
│   │   └── zsh.nix
│   ├── dotfiles
│   ├── dunst
│   ├── dwm
│   ├── fcitx5
│   ├── nvim
│   ├── picom
│   ├── rainbarf
│   ├── rofi
│   ├── thunar
│   ├── tmux
│   ├── wezterm
│   └── yazi
├── overlays
│   └── dwm.nix
└── README.md
```

## 快速开始

- 为了控制变量统一安装官网安装nix
```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

- 开启 flake
```shell
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

- 安装 home-manager
```shell
nix profile install github:nix-community/home-manager
```
> 也可以在flake.nix中去除nixgl的overlay手动安装
```shell
nix profile install github:guibou/nixGL --impure
```
> --impure 它用于放宽 Nix 的“纯模式”限制

- 指定设备

> 可以直接应用github仓库配置
```sell
home-manager switch --no-write-lock-file --flake  github:luo216/nix-config#vm-kali --impure 
```
> 也可以clone到本地
```shell
git clone https://github.com/luo216/nix-config
home-manager switch --flake .nix-config#vm-kali --impure
```

## 杂项

### 调试阶段清理缓存

- 是清理本地缓存
```shell
nix-collect-garbage -d
```

- 是清理远程仓库缓存
> 代码执行后可能是失败，但是你可以看到已经重新下载了源码，报错的只是无法重写lock文件（应该吧）
```shell
nix flake lock --recreate-lock-file github:luo216/nix-config
```

### home-manager 使用教程

- 展示所有版本
```shell
home-manager generations
```

- 回滚到上一个版本
```shell
home-manager switch --rollback
```

- 切换到指定版本
```shell
home-manager switch --generation <generation-id>
```

- 删除指定版本
```shell
home.keepGenerations = 5;
```

- 删除到指定日期
```shell
home-manager expire-generations '2025-02-19'
```

### 注意

- 我在github仓库中是没有放lock文件的，所以需要的将仓库clone到本地
- 你本地必须再下一个 `fcitx5-chinese-addons`,否则只有nix相关的应用才能使用中文输入法
