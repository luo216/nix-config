# Modular NixOS Configuration

A modular NixOS configuration system using Nix Flakes, supporting `nixos-anywhere` installation and `deploy-rs` updates.

## Features

- **Hardware Detection**: Uses `nixos-facter` for hardware-specific configurations
- **Declarative Disk Partitioning**: Manages disk layouts with `disko`
- **Remote Deployment**: `nixos-anywhere` for installation, `deploy-rs` for updates
- **Modular Design**: Reusable modules for NixOS and Home Manager
- **Multi-host**: Single flake manages NixOS machines, VMs, and non-NixOS systems

## Hosts

| Host | System | Type | Home Manager | Deploy |
|------|--------|------|-------------|--------|
| pixelbook | x86_64-linux | NixOS (GNOME/Wayland) | Integrated | `.#deploy` |
| hasee | x86_64-linux | Non-NixOS (Arch) | Standalone | - |
| tencent-cvm | x86_64-linux | NixOS (headless) | Standalone | - |
| pentest | x86_64-linux | NixOS VM | Integrated | localhost |

## Directory Structure

```
.
├── flake.nix                    # Flake entry point
├── home-manager/                # Per-host user configs
│   └── <hostname>/<username>/   # User-specific HM config
├── modules/
│   ├── home-manager/            # Reusable HM modules
│   ├── nixos/                   # Reusable NixOS modules
│   └── templates/               # Static assets (firmware, themes)
├── nixos/
│   ├── configuration.nix        # Shared NixOS config
│   ├── config/<hostname>/       # Per-host NixOS config
│   ├── disko/<hostname>.nix     # Per-host disk layout
│   └── factors/<hostname>.json  # Per-host hardware report
├── overlays/                    # Custom package overlays
└── pkgs/                        # Custom package definitions
```

## Flake Apps

```bash
nix run .#deploy              # deploy-rs CLI
nix run .#home-manager        # home-manager CLI
nix run .#build-vm-pentest    # Build VM image
nix run .#vm-pentest          # Run VM
```

## Modules

### NixOS Modules

| Module | Description |
|--------|-------------|
| `dnsmasq-dhcp` | DHCP server for device provisioning |
| `docker-easyconnect` | EasyConnect VPN in Docker with VNC |
| `network-printers` | Event-driven network printer configuration |
| `pixelbook-go-audio` | Pixelbook Go audio driver (AVS/SOF) |

### Home Manager Modules

| Module | Description |
|--------|-------------|
| `customBase` | Shared base configuration |
| `customFcitx5` | Fcitx5 input method |
| `customKitty` | Kitty terminal |
| `customTmux` | Tmux configuration |
| `customYazi` | Yazi file manager |
| `customZsh` | Zsh shell |

## Quick Start

### 1. Define Host

Add to `flake.nix` `hosts` list:

```nix
{
  hostname = "your-hostname";
  system = "x86_64-linux";
  deploy = true;           # Include in deploy-rs
  withHomeManager = true;  # Integrate HM into NixOS
  ip = "192.168.1.100";    # Required if deploy = true
  users = [{ username = "your-user"; }];
}
```

**Switches:**

- `deploy = true`: Adds host to `deploy.nodes`
- `withHomeManager = true`: Integrates users under `home-manager.users`

**HM naming:**

- Standalone: `user@host` (e.g., `steve@pixelbook`)
- Integrated: `home-manager.users.steve`

### 2. Create Disk Layout

`nixos/disko/your-hostname.nix`:

```nix
{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = { size = "512M"; type = "EF00"; content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }; };
          root = { size = "100%"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; }; };
        };
      };
    };
  };
}
```

### 3. Create Configs

| File | Purpose |
|------|---------|
| `nixos/config/<hostname>/default.nix` | NixOS system config |
| `home-manager/<hostname>/<user>/default.nix` | Home Manager user config |

Add to NixOS config for hardware detection:

```nix
{ hardware.facter.reportPath = ./factors/<hostname>.json; }
```

### 4. Install

**⚠️ Destructive — erases target disk. ⚠️**

```bash
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-facter ./nixos/factors/<hostname>.json \
  --flake .#<hostname> \
  --target-host root@<ip>
```

### 5. Deploy Updates

```bash
nix run .#deploy -- .#<hostname>

# Standalone HM
nix run .#home-manager -- switch --flake .#<user>@<host>
```

## Non-NixOS Systems

### Setup

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon
source ~/.nix-profile/etc/profile.d/nix.sh

# Configure flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
sudo bash -c 'echo "trusted-users = $USER" >> /etc/nix/nix.conf'
sudo bash -c 'echo "auto-optimise-store = true" >> /etc/nix/nix.conf'
sudo systemctl restart nix-daemon
```

### Apply

```bash
nix run .#home-manager -- switch --flake .#<user>@<host>
```

### Remote Deploy

```bash
rsync -az --delete ./ <user>@<host>:/path/to/nix-config/
ssh <user>@<host> 'zsh -lic "cd /path/to/nix-config && nix run .#home-manager -- switch --flake .#<user>@<host>"'
```

**Notes:**

- Only user-space managed
- `targets.genericLinux.enable = true` for compatibility
- `nixGL` for GPU-accelerated apps
