{
  username = "steve";

  nixosModule = {pkgs, ...}: {
    users.users.steve = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "kvm"
        "networkmanager"
        "video"
        "input"
        "uinput"
        "adbusers"
        "wireshark"
        "libvirtd"
        # 奎享雕刻写字机器人：/dev/ttyUSB0 由 udev 默认规则归到 dialout 组（0660）。
        "dialout"
      ];
      shell = pkgs.zsh;
      initialPassword = "passwd";
      # Pixelbook public key.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKEBaHem+gU3ZFXceYBSXi6tdiQ6B6fkMo2dAy3R3rQ hjzhang216@gmail.com"
      ];
    };
  };
}
