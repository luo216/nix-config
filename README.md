# Modular NixOS Configuration

A modular NixOS configuration system using Nix Flakes, deployed with deploy-rs.

## Features

- **Hardware Detection**: Uses `nixos-facter` for hardware-specific configurations
- **Declarative Disk Partitioning**: Manages disk layouts with `disko`
- **Remote Deployment**: Supports `nixos-anywhere` for installation and `deploy-rs` for updates
- **Modular Design**: Reusable modules for NixOS and Home Manager with `custom*` naming convention
- **Multi-host**: Single flake manages all hosts — NixOS machines, VMs, and non-NixOS systems

## Hosts

| Host | System | Type | Home Manager | Deploy |
|------|--------|------|-------------|--------|
| pixelbook | x86_64-linux | NixOS (GNOME/Wayland) | Integrated | deploy-rs |
| hasee | x86_64-linux | Non-NixOS (Arch) | Standalone | - |
| tencent-cvm | x86_64-linux | NixOS (headless) | Standalone | - |
| pentest | x86_64-linux | NixOS VM (headless CLI) | Integrated | - |

## Directory Structure

```
.
├── flake.nix              # Flake entry: hosts, apps, deploy
├── home-manager/          # Per-host user configs
│   ├── pixelbook/steve/   # GNOME desktop, all custom modules
│   ├── hasee/steve/       # Full desktop, genericLinux + nixGL
│   ├── pentest/pentest/   # CLI-only, pentest tools
│   └── tencent-cvm/steve/ # Minimal server
├── modules/
│   ├── home-manager/      # Custom HM modules (custom* prefix)
│   ├── nixos/             # Custom NixOS modules
│   └── templates/         # Static assets (audio firmware, themes, etc.)
├── nixos/
│   ├── configuration.nix  # Shared NixOS config (nix, SSH, HM integration)
│   ├── config/            # Per-host NixOS configs
│   ├── disko/             # Per-host disk layouts
│   └── factors/           # Per-host facter reports
├── overlays/              # Custom packages overlay + unstable nixpkgs
└── pkgs/                  # Custom package definitions
```

## Getting Started

### 1. Define the New Host

Add your machine to the `hosts` list in `flake.nix`:

```nix
hosts = [
  {
    hostname = "your-hostname";
    system = "x86_64-linux";
    deploy = true;           # Optional: include in deploy-rs
    withHomeManager = true;  # Optional: integrate HM into NixOS builds
    ip = "192.168.1.100";    # Required if deploy = true
    users = [{ username = "your-user"; }];
  }
];
```

### 2. Configure Disk Layout

Create `nixos/disko/your-hostname.nix` — see existing hosts for examples.

### 3. Add Host and User Configurations

- **NixOS Configuration**: `nixos/config/your-hostname/default.nix`
- **Home Manager Configuration**: `home-manager/your-hostname/your-user/default.nix`

### 4. Install NixOS

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#your-hostname \
  --target-host root@<target-ip>
```

### 5. Deploy Updates

```bash
# System + integrated Home Manager
nix run github:serokell/deploy-rs -- .#your-hostname

# Standalone Home Manager only
home-manager switch --flake .#your-user@your-hostname
```

## Using Home Manager on Non-NixOS Systems

For hosts like hasee (Arch Linux), only user-space is managed:

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Configure flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply Home Manager
nix run home-manager/master -- switch --flake .#steve@hasee
```

Non-NixOS profiles use `targets.genericLinux.enable = true` and `nixGL` for GPU-accelerated apps.

## VM Apps

The pentest VM can be built and run directly:

```bash
nix run .#build-vm-pentest   # Build the VM image
nix run .#vm-pentest          # Run the VM
```
