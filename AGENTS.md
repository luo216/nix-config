# AGENTS

Keep any existing repository-specific rules above this section. Use the structure below as the project context block that Codex should load automatically.

## Project Context

### Goal

- Target outcome: Add a Kali-like NixOS VM configuration in this flake repository for local Web-security learning, then expose a fast-start app entrypoint after the VM build path is validated.
- User need: A disposable local learning VM that follows Kali-style choices as closely as practical, with an X11 desktop and a Web-security-oriented toolkit.
- Intended NixOS-facing result: A `sec-lab` VM-oriented host configuration with user `sec`, buildable locally and launchable through `nix run .#vm-sec-lab`.

### Scope

- In scope: Planning the VM host direction, Kali-like X11/Xfce desktop direction, Web-security tooling direction, local VM test path, app wrapper path, and implementation task split.
- Out of scope: Immediate implementation, direct target-machine configuration, and broad non-Web-focused security tooling unless later requested.

### Constraints

- Technical constraints: Reuse the existing flake multi-host layout where practical; planning only in this role.
- Environment constraints: Repository uses a flake-based multi-host layout and now exposes the local VM app entrypoint `vm-sec-lab`.
- Safety / deployment constraints: No implementation or machine configuration before clarification and approval; SSH only for information gathering if needed.

### Solution

- High-level approach: Rework the existing VM host path into a Kali-like `sec-lab` host, keep system-critical desktop/runtime packages in NixOS, move user-oriented tools into Home Manager where appropriate, and expose a `vm-sec-lab` app after the VM launch path is verified.
- Key modules or configuration areas: `flake.nix`, `nixos/config/sec-lab/`, `nixos/disko/sec-lab.nix`, `nixos/factors/sec-lab.json`, `home-manager/sec-lab/sec/`, and possibly a reusable security-tool profile split between system and home layers.
- Validation strategy: Build `.#nixosConfigurations.sec-lab.config.system.build.vm`, run the generated VM locally, complete a first-pass NixOS acceptance for desktop/session and base system tools, then complete a second-pass Home Manager acceptance for user-scoped tools, and finally confirm `nix run .#vm-sec-lab` launches the same VM path.

### Decisions Log

- [2026-04-05] Decision: Use the existing repository host layout as the leading direction, with templates only as reference material.
  - Reason: The repo is already a flake-based multi-host NixOS config and already contains VM-oriented structure.
  - Impact: Planning focuses on adding/refining a VM host inside this repo instead of proposing a fresh starter template.
- [2026-04-05] Decision: Prefer Kali-style defaults where practical for the VM design.
  - Reason: User explicitly requested to mirror Kali Linux practices as much as possible.
  - Impact: Package selection, desktop choice, user naming, and usability defaults should bias toward Kali-like behavior unless NixOS constraints make that unsuitable.
- [2026-04-05] Decision: Use an X11 + Xfce desktop and rename the target to host `sec-lab` with user `sec`.
  - Reason: User explicitly selected X11/Kali-like desktop direction and provided the final host/user naming.
  - Impact: Planning and maintenance should target `sec-lab` as the only VM host identity in this repository.
- [2026-04-05] Decision: Scope the default toolset to Web security only.
  - Reason: User narrowed the learning focus to Web security.
  - Impact: Default package recommendations and implementation tasks should exclude unrelated wireless, AD, reverse-engineering, and broad pentest tooling unless later re-added.
- [2026-04-05] Decision: Use quick-start app name `vm-sec-lab`.
  - Reason: User selected `nix run .#vm-sec-lab`.
  - Impact: The final plan should expose a flake app under that exact name after the VM build path is validated.
- [2026-04-05] Decision: Use the default Web toolkit plus `msf` and split some packages into Home Manager when that matches user-level tooling better.
  - Reason: User accepted the recommended default set, requested Metasploit, and asked that part of the software be installed through Home Manager with post-install checks.
  - Impact: Implementation should define an explicit package split instead of dumping everything into `environment.systemPackages`, and validation must cover both system and Home Manager layers.
- [2026-04-05] Decision: Acceptance must be split into two explicit passes: NixOS first, Home Manager second.
  - Reason: User wants separate validation for base system provisioning and user-layer provisioning.
  - Impact: The final plan and feature graph should include distinct acceptance sequencing and a tool split aligned to those two layers.
- [2026-04-05] Decision: Use a fixed initial package split between NixOS and Home Manager.
  - Reason: User explicitly asked which tools belong in the system layer versus the Home Manager layer.
  - Impact: Implementer should follow this split unless a package-specific NixOS constraint forces an adjustment during implementation.

### Stage Log

- [2026-04-05] Stage change / milestone / notable result: Completed initial template/environment fit and moved to clarification.
- [2026-04-05] Stage change / milestone / notable result: Clarification reached sufficient confidence for a final plan draft covering host identity, desktop direction, tool scope, local test flow, and app naming.
