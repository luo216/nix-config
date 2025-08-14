# Per-Host NixOS Configuration

Each host has:

```text
nixos/config/<hostname>/default.nix
```

`nixos/configuration.nix` imports it dynamically from `host.hostname`.
The output layer checks that the path exists and reports what to create; it does
not generate or overwrite a host configuration.

Host files are intentionally self-contained. They include boot settings,
hardware, GNOME/GDM Wayland, fonts, packages, services, containers, and any
host-specific defaults.

`nixos/configuration.nix` only performs global wiring such as dynamic imports,
nixpkgs overlays, Nix settings, SSH defaults, and `system.stateVersion`. It is
not the place for desktop, workstation, or host policy.

Hasee additionally contains NVIDIA PRIME render offload, Steam NVIDIA defaults,
virtualization, Sunshine, and the data disk. Pixelbook contains its boot,
resume, audio, printer, and optional service settings.

## Adding a Host

1. Add the record to `outputs/hosts.nix`.
2. Create `nixos/config/<hostname>/default.nix`.
3. Create `nixos/disko/<hostname>.nix`.
4. Add `nixos/factors/<hostname>.json`.
5. Add every configured user under `nixos/users/<hostname>/`.
6. Add HM entries under `home-manager/<hostname>/` where required.
