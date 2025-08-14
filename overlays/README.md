# Nixpkgs Overlays

`overlays/default.nix` exports three overlays through `outputs/modules.nix`:

| Overlay | Purpose |
|---------|---------|
| `additions` | Adds every package registered in `pkgs/default.nix` |
| `modifications` | Patches nixpkgs; currently adjusts `stegsolve` |
| `unstable-packages` | Exposes unstable nixpkgs as `pkgs.unstable` |

NixOS applies all three overlays from `nixos/configuration.nix`. Standalone Home
Manager applies them through `home-manager/configuration.nix`; integrated HM
reuses the NixOS package set.

Add a custom package to `pkgs/default.nix` rather than editing `additions`
directly. Package overrides belong in `modifications`:

```nix
modifications = final: prev: {
  example = prev.example.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.makeWrapper];
  });
};
```
