# NixOS Shared Configuration

`configuration.nix` contains settings shared across all NixOS hosts:

- **Facter** — hardware report path
- **Networking** — `hostName` derived from flake host metadata
- **Nixpkgs** — overlays (custom packages + unstable)
- **Nix** — daemon settings (substituters, GC, registry)
- **SSH** — OpenSSH server with root authorized key
- **Home Manager** — NixOS module integration (when `withHomeManager = true`)

Per-host settings (timezone, locale, programs, services) live in `config/${hostname}/default.nix`, even if identical across hosts.

## Subdirectories

- `config/` — Per-host NixOS configurations
- `disko/` — Per-host disk partition layouts
- `factors/` — Per-host facter hardware reports