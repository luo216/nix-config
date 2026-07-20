# NixOS Users

Users are isolated first by hostname, then by username:

```text
nixos/users/
├── hasee/
│   ├── steve/default.nix
│   └── root/default.nix
└── pixelbook/
    ├── steve/default.nix
    └── root/default.nix
```

`outputs/hosts.nix` stores usernames only:

```nix
{
  hostname = "hasee";
  primaryUser = "steve";
  users = ["steve"];
}
```

`outputs/nixos-configs.nix` automatically loads each corresponding user file,
validates its username, adds the host's root user file, and adds every
`nixosModule` to the system.

This is dynamic importing, not template generation. Missing user files stop
evaluation and report the exact `default.nix` path that must be created.

## User Descriptor

```nix
{
  username = "your-user";

  nixosModule = {pkgs, ...}: {
    users.users.your-user = {
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 ..."
      ];
    };
  };
}
```

User files own their groups, shell, credentials, SSH keys, root access, and
future host-specific extensions. Root is automatically loaded for NixOS hosts
from `nixos/users/<hostname>/root/default.nix`.

`primaryUser` explicitly controls GNOME auto-login and other desktop-primary
semantics; user list order has no special meaning.

Integrated Home Manager is generated for `primaryUser`. Root remains NixOS-only
unless explicitly promoted to a standalone or primary Home Manager user.

Current SSH trust is reciprocal: Hasee accepts the Pixelbook Ed25519 key and
Pixelbook accepts the Hasee Ed25519 key for their configured Steve and Root
accounts.
