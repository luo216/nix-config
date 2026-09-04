# Reusable Modules

`outputs/modules.nix` exports these modules as `outputs.nixosModules` and
`outputs.homeManagerModules`.

## Home Manager Modules

| Module | Namespace | Purpose |
|--------|-----------|---------|
| `customCtfMsf` | `programs.customCtfMsf` | Metasploit and exploit tooling |
| `customFcitx5` | `programs.customFcitx5` | Chinese input method |
| `customFonts` | `programs.customFonts` | User fonts and fontconfig |
| `customGhostty` | `programs.customGhostty` | Ghostty terminal |
| `customRainbarf` | `programs.customRainbarf` | tmux resource monitor |
| `customTemplates` | `programs.customTemplates` | Static file mappings |
| `customTmux` | `programs.customTmux` | tmux configuration |
| `customYazi` | `programs.customYazi` | Yazi file manager |
| `customZsh` | `programs.customZsh` | Zsh environment |

## NixOS Modules

| Module | Purpose |
|--------|---------|
| `docker-easyconnect` | EasyConnect VPN container |
| `dnsmasq-dhcp` | Optional DHCP server |
| `network-printers` | Declarative network printers |
| `nps-ehang` | NPS reverse proxy service |
| `pixelbook-go-audio` | Pixelbook Go AVS audio support |
| `virtualizationHost` | libvirt, QEMU, virt-manager, and TPM support |
| `ventoy-insecure` | Ventoy insecure-package allowance |
| `wine-gui-tools` | Wine GUI runtime support |

Host workstation policy is kept directly under `nixos/config/<hostname>/`.
`modules/nixos/` is reserved for reusable option modules and small focused
support modules.

NixOS user modules are not reusable modules. They live under:

```text
nixos/users/<hostname>/<username>/default.nix
```

## Templates

`modules/templates/` contains static assets used by modules, including
wallpapers, certificates, input-method themes, tmux files, and Pixelbook audio
firmware. Third-party plugin README files are preserved unchanged.
