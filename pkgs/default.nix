# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs:
let
  claudeDesktop = pkgs.callPackage ./claude-desktop.nix { };
in
{
  # example = pkgs.callPackage ./example { };
  cc-switch-cli = pkgs.callPackage ./cc-switch-cli.nix { };
  claude-desktop = claudeDesktop;
  cloakbrowser-chromium = pkgs.callPackage ./cloakbrowser.nix { };
  codex-desktop = pkgs.callPackage ./codex-desktop-linux.nix { };
  cpa = pkgs.callPackage ./cpa.nix { };
  google-chrome-stable = pkgs.callPackage ./google-chrome-stable.nix { };
  opencode-desktop = pkgs.callPackage ./opencode-desktop.nix { };
  qq = pkgs.callPackage ./qq.nix { };
  sunshine = pkgs.callPackage ./sunshine.nix { };
  wechat = pkgs.callPackage ./wechat.nix { };
  wemeet = pkgs.callPackage ./wemeet { };
  wpsoffice-cn = pkgs.callPackage ./wpsoffice-cn.nix { };
}
