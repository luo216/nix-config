# Flake Outputs

`outputs/default.nix` imports the files below and recursively merges their
attribute sets.

| File | Output | Responsibility |
|------|--------|----------------|
| `hosts.nix` | — | Host inventory data |
| `lib.nix` | — | x86_64 system helpers and package sets |
| `packages.nix` | `packages`, `formatter` | Packages and formatter |
| `modules.nix` | modules, overlays | Reusable modules and overlays |
| `nixos-configs.nix` | `nixosConfigurations` | NixOS and integrated HM |
| `home-configs.nix` | `homeConfigurations` | Standalone HM hosts only |
| `apps.nix` | `apps` | Pinned Home Manager and deploy-rs CLIs |
| `deploy.nix` | `deploy` | Deployment nodes |

## Host Processing

For each host with `nixos = true` in `outputs/hosts.nix`,
`nixos-configs.nix`:

1. Loads every listed `nixos/users/<hostname>/<username>/default.nix`.
2. Automatically loads `nixos/users/<hostname>/root/default.nix`.
3. Validates user descriptors and `primaryUser`.
4. Adds each `nixosModule` to `nixosSystem`.
5. Integrates HM for `primaryUser` when `withHomeManager = true`.

`home-configs.nix` generates standalone outputs for every user on hosts with
`withHomeManager = false`, preventing two activation paths for the same user.
Missing Home Manager user entries stop evaluation with the required path.

The switches are orthogonal: `nixos` controls `nixosConfigurations`, while
`withHomeManager` controls integrated versus standalone HM. Consequently,
`nixos = true; withHomeManager = false;` exports both a NixOS configuration and
separate HM configurations. Host processing only detects and imports expected
paths; incomplete hosts stop evaluation, and no template files are generated.

## Validation

`nix flake check path:. --no-build` evaluates the Flake outputs without adding
separate formatting, static-analysis, or deploy-rs check derivations. Run
`nix fmt` explicitly when formatting is wanted.

## Adding an Output

1. Create `outputs/<name>.nix` returning an attribute set.
2. Import it from `outputs/default.nix`.
3. Pass only the helpers and inputs it requires.
