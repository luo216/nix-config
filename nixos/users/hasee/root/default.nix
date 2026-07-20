{
  username = "root";

  nixosModule = {
    # Pixelbook public key.
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKEBaHem+gU3ZFXceYBSXi6tdiQ6B6fkMo2dAy3R3rQ hjzhang216@gmail.com"
    ];
  };
}
