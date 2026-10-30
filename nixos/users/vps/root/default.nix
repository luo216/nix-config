{
  username = "root";

  nixosModule = {
    users.users.root.openssh.authorizedKeys.keys = [
      # hasee
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnNd0LwwqP2zdbaY9F4SjYX4Wmjkvo1aCJ0EOh37CFt hjzhang216@gmail.com"
      # pixelbook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKEBaHem+gU3ZFXceYBSXi6tdiQ6B6fkMo2dAy3R3rQ hjzhang216@gmail.com"
    ];
  };
}
