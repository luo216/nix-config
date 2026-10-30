# Host definitions. Each entry is threaded into NixOS, Home Manager, and deploy outputs.
# `ip` holds an ssh-config alias (see Share/config/ssh/), not a raw address —
# the real IP and SSH port live only in ~/.ssh/config (deploy-rs's nix copy
# ignores sshOptions, so the alias is the single port-aware entry point).
[
  {
    hostname = "hasee";
    system = "x86_64-linux";
    nixos = true;
    deploy = false;
    withHomeManager = true;
    ip = "hasee";
    primaryUser = "steve";
    users = ["steve"];
  }
  {
    hostname = "pixelbook";
    system = "x86_64-linux";
    nixos = true;
    deploy = true;
    withHomeManager = true;
    ip = "pixelbook";
    primaryUser = "steve";
    users = ["steve"];
  }
  {
    hostname = "kali";
    system = "x86_64-linux";
    nixos = false;
    deploy = false;
    withHomeManager = false;
    ip = "kali";
    users = ["test"];
  }
  {
    hostname = "vps";
    system = "x86_64-linux";
    nixos = true;
    deploy = true;
    withHomeManager = false;
    ip = "vps";
    primaryUser = "root";
    users = ["root"];
  }
]
