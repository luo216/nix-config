# Custom Modules

Exported as `outputs.nixosModules` and `outputs.homeManagerModules` via `outputs/modules.nix`.

## home-manager/

Reusable Home Manager modules with `custom*` prefix:

| Module | Namespace | Description |
|--------|-----------|-------------|
| customBase | `customBase` | Shared defaults (nix.gc, home-manager enable, nixpkgs handling) |
| customCpa | `services.customCpa` | CPA proxy client |
| customFcitx5 | `programs.customFcitx5` | Input method framework |
| customFonts | `programs.customFonts` | Font packages |
| customKitty | `programs.customKitty` | Terminal emulator |
| customRainbarf | `programs.customRainbarf` | tmux status bar |
| customTemplates | `programs.customTemplates` | Template files |
| customTmux | `programs.customTmux` | Terminal multiplexer |
| customYazi | `programs.customYazi` | File manager |
| customZsh | `programs.customZsh` | Shell configuration |

## nixos/

Reusable NixOS modules:

| Module | Description |
|--------|-------------|
| docker-easyconnect | EasyConnect VPN in Docker |
| dnsmasq-dhcp | DHCP server for device provisioning |
| network-printers | Declarative network printer setup |
| pixelbook-go-audio | Pixelbook Go AVS audio firmware support |
| virtualizationHost | libvirt + virt-manager host setup |

## templates/

Static assets used by modules:
- `chromebook-audio/` — AVS topology firmware for Pixelbook Go
- `fcitx5-themes/` — Input method themes
- `tmux/` — tmux configuration files
- `wallpaper/` — Desktop wallpapers
