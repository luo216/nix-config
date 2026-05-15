# Flake Outputs

Flake outputs split into per-concern modules, merged by `default.nix` via `builtins.foldl'`.

| File | Output | Description |
|------|--------|-------------|
| `default.nix` | — | Orchestrator — imports & merges all sub-modules |
| `hosts.nix` | — | Host definitions (data, no logic) |
| `lib.nix` | — | Shared helpers (`systems`, `forAllSystems`, `pkgsFor`) |
| `packages.nix` | `packages`, `formatter` | Custom packages per system |
| `modules.nix` | `overlays`, `nixosModules`, `homeManagerModules` | Reusable modules |
| `nixos-configs.nix` | `nixosConfigurations` | NixOS system configs per host |
| `home-configs.nix` | `homeConfigurations` | Standalone Home Manager configs |
| `apps.nix` | `apps` | CLI launchers & VM scripts |
| `deploy.nix` | `deploy`, `checks` | deploy-rs node definitions & checks |

## Adding a new output type

1. Create `outputs/<name>.nix` — a function returning the attrset to merge
2. Add it to the list in `default.nix`
3. If it needs shared helpers, import from `lib.nix`

## Host conventions

Hosts are defined in `hosts.nix` as a flat list. Each entry drives:

- `nixosConfigurations.<hostname>` — if `nixos/config/<hostname>/default.nix` exists
- `homeConfigurations.<user>@<hostname>` — for each user in `host.users`
- `deploy.nodes.<hostname>` — if `host.deploy = true` and `host.ip` is set
- `apps.build-vm-<hostname>` / `apps.vm-<hostname>` — if VM config exists
