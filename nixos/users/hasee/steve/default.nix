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
