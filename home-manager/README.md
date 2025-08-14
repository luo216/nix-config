# Home Manager Configurations

Home Manager entries use the layout:

```text
home-manager/configuration.nix
home-manager/<hostname>/<username>/default.nix
```

`home-manager/configuration.nix` is called by both integrated and standalone
outputs with `host` and `user`. It dynamically imports
`home-manager/<hostname>/<username>/default.nix`, then applies shared Home
Manager defaults:

- `home.stateVersion`
- `systemd.user.startServices`
- Home Manager CLI enablement
- Home Manager garbage collection
- Standalone-only Stylix, overlays, and unfree-package policy

The same entry is used in one of two modes:

- Integrated host (`withHomeManager = true`): loaded by `outputs/nixos-configs.nix`.
- Standalone host (`withHomeManager = false`): exported by `outputs/home-configs.nix`.

Only one activation mode is exposed for each host. `hasee` and `pixelbook` are
integrated; `test@kali` is exported as a standalone Home Manager configuration.
Integrated hosts manage `primaryUser` with Home Manager. Standalone hosts
generate Home Manager outputs for every listed user. This is independent of
the `nixos` switch: a NixOS host can use standalone HM to keep its HM generation
separate from system generations.

The output code checks `home-manager/<hostname>/<username>/default.nix` and
stops evaluation with the exact missing path. It does not create or modify the
file.

## Layout

Home Manager configuration is kept at the user entry point. Shared behavior is
not split into `profiles/`; if a host or user needs a package, desktop setting,
or service, put it directly in:

```text
home-manager/<hostname>/<username>/default.nix
```

This keeps hasee, pixelbook, and standalone Kali easy to inspect and modify
without chasing profile composition.

Custom option modules remain under `modules/home-manager/` with namespaces such
as `programs.customZsh` and `programs.customGhostty`. These modules encapsulate
program details, but each user file decides which modules to import and enable.

Root's system account and SSH keys remain in `nixos/users/`; root is not managed
by Home Manager.

## Standalone Hosts

For a host with `withHomeManager = false`:

```bash
nix run .#home-manager -- switch --flake .#<user>@<host>
```

Standalone outputs are generated for every user listed on standalone hosts.
Missing HM entries fail during evaluation.

Kali uses this mode:

```bash
nix run path:.#home-manager -- switch --flake path:.#test@kali -b hm-backup
```

## Kali Bootstrap

Kali is not managed by NixOS. User creation, SSH access, sudo, and the Nix
daemon are therefore one-time imperative bootstrap steps.

From Hasee, connect with the existing Kali administrator and create `test`:

```bash
ssh kali@192.168.122.117

sudo useradd --create-home --shell /usr/bin/zsh --groups sudo test
sudo install -d -m 0700 -o test -g test /home/test/.ssh
sudoedit /home/test/.ssh/authorized_keys
sudo chown test:test /home/test/.ssh/authorized_keys
sudo chmod 0600 /home/test/.ssh/authorized_keys

echo 'test ALL=(ALL:ALL) NOPASSWD: ALL' \
  | sudo tee /etc/sudoers.d/90-test >/dev/null
sudo chmod 0440 /etc/sudoers.d/90-test
sudo visudo -cf /etc/sudoers.d/90-test
```

Put Hasee's `~/.ssh/id_ed25519.pub` in `authorized_keys`, then verify access:

```bash
ssh -o BatchMode=yes test@192.168.122.117 'id; sudo -n true'
```

Install Nix from the Kali repository and enable Flakes:

```bash
ssh test@192.168.122.117

sudo apt-get update
sudo apt-get install -y nix-bin nix-setup-systemd

printf '%s\n' \
  'experimental-features = nix-command flakes' \
  'trusted-users = root test' \
  | sudo tee /etc/nix/nix.conf >/dev/null

sudo systemctl enable --now nix-daemon.socket
sudo systemctl start nix-daemon.service
sudo usermod -aG nix-users test
```

Reconnect after adding the group, then verify the daemon:

```bash
ssh test@192.168.122.117
id
nix --version
nix store info --store daemon
```

Synchronize the working tree from Hasee and activate Home Manager:

```bash
rsync -a --delete \
  --exclude .git \
  --exclude .codex \
  --exclude result \
  /home/steve/Share/nix-config/ \
  test@192.168.122.117:/home/test/nix-config/

ssh test@192.168.122.117
cd ~/nix-config
nix flake check --no-build path:.
nix run path:.#home-manager -- switch --flake path:.#test@kali -b hm-backup
```

The backup suffix preserves Kali's original `.zshrc` as `.zshrc.hm-backup`
during the first activation. The `test@kali` configuration does not manage the
XFCE terminal helper, so Kali's native QTerminal remains the default.
