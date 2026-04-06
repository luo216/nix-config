# Modular NixOS Configuration

A modular and scalable NixOS configuration system using Nix Flakes.

## ✨ Features

- **🦾 Automatic Hardware Detection:** Uses `nixos-facter` to generate hardware-specific configurations.
- **💾 Declarative Disk Partitioning:** Manages disk layouts declaratively with `disko`.
- **🚀 Remote Deployment:** Supports remote installation with `nixos-anywhere` and updates with `deploy-rs`.
- **🧩 Modular Design:** Features a clean structure with reusable modules for NixOS and Home Manager.
- **🖥️ Pre-configured Modules:** Includes ready-to-use modules for `dwm`, `rofi`, `fcitx5`, `yazi`, and more.

## 📁 Directory Structure

```
.
├── flake.nix
├── home-manager
│   ├── hasee
│   │   └── steve
│   ├── pixelbook
│   │   └── steve
│   ├── sec-lab
│   │   └── sec
├── modules
│   ├── home-manager
│   ├── nixos
│   └── templates
├── nixos
│   ├── config
│   │   ├── pixelbook
│   │   └── sec-lab
│   ├── configuration.nix
│   ├── disko
│   └── factors
├── overlays
└── pkgs
```

## 🚀 Getting Started

### 1. Define the New Host

Add your new machine to the `hosts` list in `flake.nix`.

```nix
# flake.nix
hosts = [
  {
    hostname = "your-hostname";
    system = "x86_64-linux";
    deploy = true; # Optional: include this host in deploy-rs
    withHomeManager = true; # Optional: integrate Home Manager into NixOS builds
    ip = "192.168.1.100"; # For deploy-rs
    users = [ { username = "your-user"; } ];
  }
];
```

Host flags:

- `deploy = true`: include the host in `deploy.nodes` for `deploy-rs`
- `withHomeManager = true`: include all users for that host in `home-manager.users` during NixOS builds

Home Manager naming:

- Standalone Home Manager outputs use `user@host`, for example `steve@pixelbook`
- NixOS-integrated Home Manager still uses the real username internally, for example `home-manager.users.steve`
- This lets the same host support both standalone Home Manager updates and NixOS-integrated updates

Shared Home Manager base module:

- `modules/home-manager/base.nix` provides common Home Manager defaults shared by user profiles
- It centralizes `nix.gc`, `programs.home-manager.enable`, and standalone-vs-integrated `nixpkgs` handling
- New user profiles should usually import `outputs.homeManagerModules.base` first, then add host- or user-specific modules

### 2. Configure Disk Layout

Create a disk layout for the new host in `nixos/disko/your-hostname.nix`.

```nix
# nixos/disko/your-hostname.nix
{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda"; # Change this to your disk device
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

### 3. Add Host and User Configurations

Create the necessary directories and configuration files for the new host and user. You can copy and adapt them from an existing host directory that matches your target layout.

- **NixOS Configuration:** `nixos/config/your-hostname/`
- **Home Manager Configuration:** `home-manager/your-hostname/your-user/`

### 4. Install NixOS

Install NixOS on the target machine using `nixos-anywhere`. This command will automatically detect the hardware, generate a configuration file, and install the system.

**⚠️ This is a destructive operation and will wipe the target disk. ⚠️**

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#your-hostname \
  --target-host root@<target-ip>
```

### 5. Deploy Configuration

After installation, you can manage and deploy updates using `deploy-rs`.

```bash
# Deploy changes to the host
nix run github:serokell/deploy-rs -- .#your-hostname
```

For user-specific settings, apply them with Home Manager directly on the target machine.

```bash
# On the target machine
home-manager switch --flake .#your-user@your-hostname
```

Notes for NixOS hosts:

- If `withHomeManager = true`, `nixos-rebuild` and `deploy-rs` will update the host's integrated Home Manager profiles together with the system
- You can still use standalone Home Manager outputs such as `homeConfigurations."your-user@your-hostname"` for user-only updates
- On `pixelbook`, Stylix is managed at the system level; the user Home Manager profile does not define Stylix separately

## 🐧 Using Home Manager on Non-NixOS Systems

If you want to use Home Manager to manage your user configuration on Non-NixOS systems like Arch Linux, Ubuntu, or Fedora, follow these steps:

### 1. Install Nix

Install Nix using the official installation script:

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

After installation, you need to either reopen your terminal or run:

```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### 2. Configure Flakes and Trusted User

Enable Flakes feature and set the current user as trusted user (required to use cache servers configured in flake.nix):

```bash
# Create user-level config directory
mkdir -p ~/.config/nix

# Enable Flakes experimental features (user-level)
cat >> ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF

# Set current user as trusted user (requires sudo, system-level)
sudo bash -c 'echo "trusted-users = steve" >> /etc/nix/nix.conf'

# Enable automatic Nix store optimization (saves disk space)
sudo bash -c 'echo "auto-optimise-store = true" >> /etc/nix/nix.conf'

# Restart nix-daemon service
sudo systemctl restart nix-daemon
```

**About auto-optimise-store:**
- This option automatically detects duplicate files in the Nix store and eliminates them via hard links
- Typically saves 20-40% of disk space
- Runs automatically after each build, no manual intervention needed
- Completely transparent to users and programs

### 3. Install Home Manager

Install Home Manager using Flakes:

```bash
nix run home-manager/master -- switch --flake .#your-user@your-hostname
```

For example, for the steve user on hasee host:

```bash
nix run home-manager/master -- switch --flake .#steve@hasee
```

### 4. Apply Configuration

To update your configuration in the future, simply run:

```bash
home-manager switch --flake .#your-user@your-hostname
```

### Notes

- On Non-NixOS systems, you can only manage your user environment with Home Manager. NixOS system-level configurations are not available.
- Home Manager will automatically install necessary dependencies, but some system-level features may require manual configuration.
- The configuration includes `targets.genericLinux.enable = true` for better Linux compatibility.
