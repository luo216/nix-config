# Custom Packages

`pkgs/default.nix` registers local packages with `callPackage`. They are exposed
both as Flake packages and through the `additions` overlay.

## Packages

| Package | Purpose |
|---------|---------|
| `cc-switch-cli` | CLI configuration switcher for AI coding tools |
| `cisco-packettracer` | Cisco Packet Tracer |
| `codex-desktop` | Codex Desktop Linux package |
| `google-chrome-stable` | Google Chrome Stable |
| `hmcl-nvidia` | HMCL wrapped with NVIDIA PRIME offload variables |
| `nps-ehang` | Customized NPS reverse proxy package |
| `qq` | QQ Linux client |
| `sunshine` | Sunshine game-streaming host package |
| `wechat` | WeChat Linux client |
| `wemeet` | Tencent Meeting with local compatibility fixes |
| `wpsoffice-cn` | Chinese WPS Office package |

## Adding a Package

1. Create `pkgs/<name>.nix` or `pkgs/<name>/default.nix`.
1. Register it in `pkgs/default.nix`:

```nix
my-package = pkgs.callPackage ./my-package.nix {};
```

1. Evaluate or build it:

```bash
nix build --no-link path:.#my-package
```

Use `pkgs.<name>` inside NixOS and Home Manager after the additions overlay is
applied.
