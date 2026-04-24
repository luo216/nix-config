# Nixpkgs Overlays

- **additions** — Custom packages from `../pkgs/` directory
- **unstable-packages** — Unstable nixpkgs accessible via `pkgs.unstable`

To override or patch an existing package, add a `modifications` overlay:

```nix
modifications = final: prev: {
  example = prev.example.overrideAttrs (old: rec {
    version = "1.2.3";
    src = prev.fetchFromGitHub {
      owner = "example";
      repo = "example";
      rev = version;
      hash = "sha256-...";
    };
  });
};
```