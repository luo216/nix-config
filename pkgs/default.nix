# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
# claude-desktop-fhs wraps the local claude-desktop, so build it here via
# callPackage's override set instead of relying on name-based auto-injection.
pkgs: let
  claude-desktop = pkgs.callPackage ./claude-desktop.nix {};
in {
  # example = pkgs.callPackage ./example { };
  cc-switch-cli = pkgs.callPackage ./cc-switch-cli.nix {};
  cisco-packettracer = pkgs.callPackage ./cisco-packettracer.nix {};
  inherit claude-desktop;
  claude-desktop-fhs = pkgs.callPackage ./claude-desktop-fhs.nix {inherit claude-desktop;};
  codex-desktop = pkgs.callPackage ./codex-desktop-linux.nix {};
  google-chrome-stable = pkgs.callPackage ./google-chrome-stable.nix {};
  hmcl-nvidia = pkgs.callPackage ./hmcl-nvidia.nix {};
  nps-ehang = pkgs.callPackage ./nps-ehang.nix {};
  qq = pkgs.callPackage ./qq.nix {};
  sunshine = pkgs.callPackage ./sunshine.nix {};
  todesk = pkgs.callPackage ./todesk.nix {};
  wechat = pkgs.callPackage ./wechat.nix {};
  wemeet = pkgs.callPackage ./wemeet {};
  wpsoffice-cn = pkgs.callPackage ./wpsoffice-cn.nix {};
}
