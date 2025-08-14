{
  username = "steve";

  nixosModule = {pkgs, ...}: {
    users.users.steve = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "networkmanager"
        "video"
        "adbusers"
      ];
      shell = pkgs.zsh;
      # Hasee public key.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
      ];
    };
  };
}
