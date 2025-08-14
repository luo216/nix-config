# Host definitions. Each entry is threaded into NixOS, Home Manager, and deploy outputs.
[
  {
    hostname = "hasee";
    system = "x86_64-linux";
    nixos = true;
    deploy = false;
    withHomeManager = true;
    ip = "192.168.31.129";
    primaryUser = "steve";
    users = [ "steve" ];
  }
  {
    hostname = "pixelbook";
    system = "x86_64-linux";
    nixos = true;
    deploy = true;
    withHomeManager = true;
    ip = "192.168.31.76";
    primaryUser = "steve";
    users = [ "steve" ];
  }
  {
    hostname = "kali";
    system = "x86_64-linux";
    nixos = false;
    deploy = false;
    withHomeManager = false;
    ip = "192.168.122.117";
    users = [ "test" ];
  }
]
