# Per-Host Home Manager Configurations

Each subdirectory follows the pattern `hostname/user/default.nix`, matching the `homeConfigurations` output in `flake.nix`.

## Integration Modes

- **Integrated** (`withHomeManager = true` in flake.nix): HM is part of NixOS build, updated via `nixos-rebuild` or `deploy-rs`
- **Standalone**: HM is independent, updated via `home-manager switch --flake .#user@hostname`

## Module Imports

All configs import `outputs.homeManagerModules.customBase` first, then add host-specific modules:

```nix
imports = [
  outputs.homeManagerModules.customBase
  outputs.homeManagerModules.customZsh
  # ... other custom* modules
];
```

Custom modules use the `custom*` naming convention for both files and option namespaces (e.g., `programs.customZsh`, `services.customCpa`).