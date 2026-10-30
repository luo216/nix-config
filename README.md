# NixOS Configuration

Multi-host NixOS 26.05 configuration for x86_64 Linux desktops. The flake
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

Reinstall a host from scratch (details in [Installation](#installation)):

```bash
nix run .#install -- vps
```

## Externally Managed Software

A handful of tools are intentionally kept outside the Nix store. They live in
`~/.npm-global` (the prefix set by `NPM_CONFIG_PREFIX` in
`modules/home-manager/customZsh.nix`) and are installed/updated with `npm`, not
Nix. Launchers and wrappers below only **launch** them; they do not install
them, so a missing install shows up as a failed service rather than a failed
build.

| Tool | npm package | Launched by | Install |
|------|-------------|-------------|---------|
| Codex CLI | `@openai/codex` | `codex-desktop` wrapper | `npm i -g @openai/codex` |

`codex-desktop` (`pkgs/codex-desktop-linux.nix`) resolves its CLI through, in
order: `CODEX_CLI_PATH`, `~/.npm-global/bin/codex`, `~/.local/bin/codex`,
`~/.bun/bin/codex`, `~/.local/share/pnpm/codex`, then the system `codex`.

`cc-switch` (`pkgs/cc-switch-cli.nix`) switches provider profiles for Claude
Code, Codex, Gemini, OpenCode, and OpenClaw. Install whichever of those CLIs
you use:

```bash
npm i -g @anthropic-ai/claude-code   # Claude Code → `claude`
npm i -g @openai/codex               # Codex → `codex`
npm i -g @google/gemini-cli          # Gemini CLI
npm i -g opencode-ai                 # OpenCode → `opencode`
```

When a new launcher module or wrapper expects an npm-installed binary, add it
to this list.

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

## Windows Fonts

Windows font files (SimHei, YaHei, Calibri, Arial, …) are **not stored in the
git repository**. They are hosted as tarballs in the
[`fonts-v1` GitHub Release](https://github.com/luo216/nix-config/releases/tag/fonts-v1)
and downloaded at build time by `modules/home-manager/customFonts.nix` via
`fetchurl`.

| Tarball | Contents |
|---------|----------|
| `fonts-cjk-zhcn.tar.gz` | 中文核心：宋体、黑体、楷体、仿宋、微软雅黑、等线 |
| `fonts-western.tar.gz` | 西文 + 符号：Arial、Times、Calibri、Consolas、Wingdings … |

### Adding or removing fonts

1. Edit the font files locally.
2. Repack the affected tarball:
   ```bash
   tar czf fonts-cjk-zhcn.tar.gz <font files...>
   ```
3. Upload to the existing release (overwrites the old asset):
   ```bash
   gh release upload fonts-v1 fonts-cjk-zhcn.tar.gz --clobber
   ```
4. Update the `hash` in `customFonts.nix`:
   ```bash
   nix store prefetch-file https://github.com/luo216/nix-config/releases/download/fonts-v1/fonts-cjk-zhcn.tar.gz
   ```
5. Commit and rebuild.

## Secret Management

Secrets are plaintext Nix values in `secrets/local.nix`, encrypted at rest in git by
[git-crypt](https://github.com/AGWA/git-crypt). The repository and GitHub only store
ciphertext; the local working tree is decrypted by the smudge filter.

Pipeline:

1. `secrets/local.nix` — plaintext attribute set, tracked by git but encrypted through
   the `filter=git-crypt` rule in `.gitattributes`.
2. `git-crypt` — decrypts the working tree after `git-crypt unlock <keyfile>`; the key is
   never committed.
3. `outputs/default.nix` — imports the file and exposes it as `outputs.secrets`.
4. Host/user modules — read `outputs.secrets.<name>` and pass the string straight into
   the option (`environment`, `apiToken`, `adminPassword`, …).

Public SSH keys for `openssh.authorizedKeys` are inlined in each
`nixos/users/<host>/<user>/default.nix`.

### Key and clones

The repository key is kept outside the repo at `~/.config/git-crypt/nix-config.key`
(mode 0600). Back it up; without it the committed ciphertext cannot be recovered.

After cloning on a new machine:

```bash
git-crypt unlock ~/.config/git-crypt/nix-config.key
```

Until then `secrets/local.nix` contains ciphertext. Nix reads the working tree, so
evaluation without unlocking fails with a syntax error rather than using wrong values.

### Editing secrets

Edit `secrets/local.nix` directly; it stays plaintext in the working tree.
`git add`/`git commit` run the clean filter and store ciphertext. Each attribute is a
plain Nix value:

```nix
{
  defaultPasswd = "...";
  codeServerPassword = "...";
  cpaApiKey = "...";
  cpaManagementKey = "...";
  cfDnsToken = "...";
  cloudflaredToken = "...";
}
```

### Adding a secret

There is no registration step: add an attribute to `secrets/local.nix`, then read
`outputs.secrets.<name>` in the module that needs it.

```nix
# add this line inside the attribute set in secrets/local.nix
someServiceToken = "s3cr3t";
```

```nix
# nixos/config/<host>/default.nix  (outputs is already a module argument)
environment.etc."some-service/token".text = outputs.secrets.someServiceToken;
```

Attribute names are free-form. A module that references a name missing from
`secrets/local.nix` fails evaluation with `attribute 'someServiceToken' missing`.

Every machine that evaluates the flake needs the git-crypt key and an unlocked working
tree. deploy-rs builds on the machine you run it from, so the target host does not need
it.

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

Disk installation is destructive. **The flake ships a one-command installer** —
works for any `nixos = true` host in `outputs/hosts.nix`:

```bash
nix run .#install -- <hostname>          # e.g. vps, hasee, pixelbook
```

The app is generated from the host inventory (hosts reference ssh-config
aliases, so the installer and deploy-rs resolve addresses and ports from
`~/.ssh/config`), runs the full `nixos-anywhere` pipeline
(`kexec,disko,install,reboot`) in one pass, and needs **no external network
access on the target**: the kexec tarball is uploaded from the local
`artifacts/` copy and the closure is built locally, then both are pushed over
SSH.

Preparing the kexec tarball (450 MB, gitignored, only needed once):

```bash
nix build github:nix-community/nixos-images#packages.x86_64-linux.kexec-installer-nixos-unstable-noninteractive
cp result/nixos-kexec-installer-*.tar.gz artifacts/
```

Bootstrap notes learned from real installs:

- Fresh images often ship `PubkeyAuthentication no`; enable it and install
  the admin public keys before running the installer.
- The target only needs SSH + `tar`/`gzip` (and `kexec` via the distro
  package manager for non-NixOS targets). Everything else comes from here.
- Never reboot between the disko and install phases — the disk has no
  bootloader until `install` completes, and a reboot there bricks the
  machine into the provider rescue system.

Manual invocation (e.g. generating a new facter report on unknown hardware):

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

