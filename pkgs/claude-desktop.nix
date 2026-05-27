{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "aaddrick";
    repo = "claude-desktop-debian";
    rev = "98232dbd81591eae64d565fff856e80c5c6ef08b";
    hash = "sha256-woTHicw3feGdE4AmnHKDocoga3ZTNkFkzfRhug98oMo=";
  };

  node-pty = callPackage "${src}/nix/node-pty.nix" { };

  claude-desktop-unwrapped = callPackage "${src}/nix/claude-desktop.nix" {
    inherit node-pty;
  };
in
claude-desktop-unwrapped
