# NixOS Configuration

Multi-host NixOS 25.11 configuration for x86_64 Linux desktops. The flake
manages NixOS systems, per-host users, integrated Home Manager, custom packages,
disk layouts, hardware reports, and deploy-rs nodes.

## Hosts

| Host | Desktop | Primary user | Home Manager | Deploy target |
|------|---------|--------------|--------------|---------------|
| `pixelbook` | GNOME Wayland | `steve` | Integrated | `192.168.31.76` |
| `hasee` | GNOME Wayland | `steve` | Integrated | `192.168.31.129` |
| `kali` | XFCE X11 | `test` | Standalone (`test@kali`) | `192.168.122.117` |

Hasee uses Intel for GNOME and display output. NVIDIA PRIME render offload is
enabled for selected applications; Steam and HMCL default to the RTX 3050.

## Architecture

```text
flake.nix
├── outputs/                 Flake output orchestration
│   ├── hosts.nix            Host inventory data
│   ├── nixos-configs.nix    Hosts, users, integrated HM, nixosConfigurations
│   ├── home-configs.nix     Standalone HM hosts only
│   ├── deploy.nix           deploy-rs nodes and checks
│   └── packages.nix         Packages and formatter
├── nixos/
│   ├── configuration.nix    Shared NixOS settings
│   ├── config/<host>/       Machine-specific configuration
│   ├── users/<host>/<user>/ Per-machine NixOS user modules
│   ├── disko/               Disk layouts
│   └── factors/             nixos-facter reports
├── home-manager/
│   ├── configuration.nix    Shared HM entry point and defaults
│   └── <host>/<user>/       Per-machine HM user configuration
├── modules/                 Reusable NixOS and HM modules
├── overlays/                Custom, modified, and unstable packages
└── pkgs/                    Custom package definitions
```

The dependency path is:

```text
flake.nix
→ outputs/default.nix
→ outputs/hosts.nix
→ outputs/nixos-configs.nix
→ nixos/configuration.nix
→ nixos/config/<host> and nixos/users/<host>/<user>
```

Home Manager follows the same entry-point pattern:

```text
outputs/nixos-configs.nix or outputs/home-configs.nix
→ home-manager/configuration.nix
→ home-manager/<host>/<user>/default.nix
```

## Host Inventory

Hosts are declared in `outputs/hosts.nix`:

```nix
{
  hostname = "hasee";
  system = "x86_64-linux";
  nixos = true;
  deploy = true;
  withHomeManager = true;
  ip = "192.168.31.129";
  primaryUser = "steve";
  users = ["steve"];
}
```

`nixos` is required, and it is independent from `withHomeManager`. `nixos = true`
means that the host already has a NixOS configuration: its files are validated,
then exposed as `nixosConfigurations.<hostname>`. Every declared user plus root
is loaded from `nixos/users/`. `withHomeManager` only selects whether HM is
integrated into that NixOS output or exported independently.

Host declarations never create or overwrite configuration files. Evaluation
stops with the exact paths to create when a required NixOS, user, disko, facter,
or Home Manager file is missing.

## Home Manager Modes

Each HM configuration has exactly one activation mode:

- `withHomeManager = true`: HM follows NixOS rebuilds or deploy-rs.
- `withHomeManager = false`: standalone HM outputs are generated.

Hasee and Pixelbook use integrated Home Manager. Kali exports the standalone
`test@kali` configuration. Integrated Home Manager is generated for
`primaryUser`; standalone Home Manager is generated for each user listed on a
host. A NixOS host may set `withHomeManager = false` to keep NixOS and HM
activations, and therefore their generations, separate.

## Common Commands

Show outputs:

```bash
nix flake show
```

Format Nix files:

```bash
nix fmt
```

Evaluate the Flake outputs:

```bash
nix flake check path:. --no-build
```

Build a system without activating it:

```bash
nix build --no-link path:.#nixosConfigurations.hasee.config.system.build.toplevel
```

Deploy a configured host:

```bash
nix run .#deploy -- .#hasee
```

## Adding a Host

Add the host record to `outputs/hosts.nix`. No template files are generated.

For `nixos = true`, create:

```text
nixos/config/<hostname>/default.nix
nixos/disko/<hostname>.nix
nixos/factors/<hostname>.json
nixos/users/<hostname>/<username>/default.nix
nixos/users/<hostname>/root/default.nix
```

For Home Manager, create
`home-manager/<hostname>/<username>/default.nix`. With integrated HM only the
`primaryUser` entry is required; with standalone HM every listed user needs an
entry. Evaluation reports any missing path and never fills it automatically.

## Adding a User

Add the username to the host:

```nix
users = ["steve" "kali"];
```

Then create:

```text
nixos/users/<hostname>/kali/default.nix
home-manager/<hostname>/kali/default.nix  # required when the host uses HM
```

The user descriptor must define `username` and `nixosModule`.

## Installation

Disk installation is destructive. From a NixOS installer, a typical
`nixos-anywhere` invocation is:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --phases disko,install,reboot \
  --generate-hardware-config nixos-facter ./nixos/factors/<hostname>.json \
  --flake .#<hostname> \
  --target-host nixos@<installer-ip> \
  --sudo
```

The user performs builds, installation, activation, reboot, and runtime
validation.
