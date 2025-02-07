# 基本的NixOS配置
{ config, pkgs, ... }:

{
  imports = [
    # 包含硬件配置扫描的结果
    ./hardware-configuration.nix
  ];

  # 使用systemd-boot引导加载器
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络配置
  networking.hostName = "nixos"; # 定义你的主机名
  networking.networkmanager.enable = true; # 启用NetworkManager
  
  # 设置时区
  time.timeZone = "Asia/Shanghai";

  # 国际化设置
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # X11窗口系统配置
  services.xserver.enable = true;
  
  # 启用GNOME桌面环境
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # 键盘映射配置
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # 启用CUPS来打印文档
  services.printing.enable = true;

  # 启用声音（使用pipewire）
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 启用触摸板支持（仅适用于大多数笔记本电脑）
  # services.xserver.libinput.enable = true;

  # 定义用户账户
  users.users.steve = {
    isNormalUser = true;
    description = "Steve";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # 用户特定的包
    ];
  };

  # 允许安装不自由软件
  nixpkgs.config.allowUnfree = true;

  # 系统范围的包列表
  environment.systemPackages = with pkgs; [
    vim # 不要忘记添加一个编辑器来编辑configuration.nix！nixos-rebuild也需要它
    wget
    curl
    git
    firefox
    htop
    tree
  ];

  # 一些程序需要SUID wrappers，可以用programs.mtr配置
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # 启用openssh守护进程的服务列表
  # services.openssh.enable = true;

  # 打开防火墙中的端口
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # 或者完全禁用防火墙
  # networking.firewall.enable = false;

  # 这个值决定了NixOS应该与你当前的系统状态兼容
  # 在升级NixOS时，这个值应该保持不变
  # 只有在手动升级后，你才应该增加这个值
  # 参见 https://nixos.org/manual/nixos/stable/#sec-upgrading-nixos
  system.stateVersion = "23.11"; # 根据你的NixOS版本调整
} 