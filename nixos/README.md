# NixOS Configuration Layer

`nixos/configuration.nix` is the shared system module. It contains only common
NixOS settings and machine-path imports:

- Hostname, facter report, disk layout, and per-host configuration.
- Nixpkgs overlays and unfree-package policy.
- Nix daemon, registry, mirrors, optimisation, and garbage collection.
- Shared OpenSSH server policy.
- NixOS compatibility default, including `system.stateVersion`.

Multi-host and multi-user orchestration belongs to
`outputs/nixos-configs.nix`, including:

- Loading `nixos/users/<host>/<user>` descriptors.
- Validating users and `primaryUser`.
- Adding NixOS user modules.
- Configuring trusted Nix users.
- Integrating Home Manager for every listed user when enabled.

## Directories

| Directory | Purpose |
|-----------|---------|
| `config/` | Machine-specific boot, hardware, packages, services, and storage |
| `users/` | Per-machine NixOS users and SSH access |
| `disko/` | Declarative disk layouts |
| `factors/` | nixos-facter hardware reports |

The normal evaluation path is:

```text
outputs/nixos-configs.nix
→ nixos/configuration.nix
→ nixos/config/<hostname>/default.nix
→ imported service modules
```
