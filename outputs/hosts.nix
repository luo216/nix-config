# Host definitions.  Add / remove machines by editing this list.
# Each entry is threaded into nixosConfigurations, homeConfigurations, deploy nodes, and VM apps.
[
  {
    hostname = "pixelbook";
    system = "x86_64-linux";
    deploy = true;
    withHomeManager = true;
    ip = "192.168.31.76";
    users = [{ username = "steve"; }];
  }
  {
    hostname = "hasee";
    system = "x86_64-linux";
    deploy = true;
    withHomeManager = true;
    ip = "192.168.31.129";
    users = [{ username = "steve"; }];
  }
]
