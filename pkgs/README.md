# Custom Package Definitions

Each `.nix` file defines a package available via the `additions` overlay (`pkgs/default.nix`).

Add a new package: create a `.nix` file here, then register it in `default.nix` with `callPackage`.

Build any package directly:
```
nix build .#qq
nix build .#wechat
```

## Current Packages

| Package | Description |
|---------|-------------|
| cc-switch-cli | CLI tool for switching Claude Code sessions |
| claude-desktop | Claude Desktop (aaddrick packaging) |
| codex-desktop | Codex Desktop (ilysenko Linux build) |
| cpa | CLI Proxy API client |
| google-chrome-stable | Google Chrome Stable from Google's current deb |
| qq | QQ (Linux) |
| wechat | WeChat (Linux AppImage) |
| wemeet | Tencent WeMeet with Wayland screenshare support |
| wpsoffice-cn | WPS Office (Chinese) |
