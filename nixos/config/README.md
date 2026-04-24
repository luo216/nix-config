# Per-Host NixOS Configurations

Each subdirectory is a NixOS host, loaded by `configuration.nix` via:

```nix
imports = [ ./config/${host.hostname}/default.nix ];
```

## Structure

Each host config should include its own:
- Boot/loader settings
- Networking (firewall, NetworkManager, DHCP)
- Timezone, locale, console
- Users and groups
- System packages
- Programs and services
- Virtualization settings

Only `networking.hostName` is set in the shared `configuration.nix` (derived from `host.hostname`).

## Adding a New Host

1. Create `./your-hostname/default.nix`
2. Add corresponding `nixos/disko/your-hostname.nix`
3. Add placeholder `nixos/factors/your-hostname.json`
4. Register the host in `flake.nix` hosts list
