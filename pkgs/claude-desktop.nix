{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "aaddrick";
    repo = "claude-desktop-debian";
    rev = "3a013797926057145625c6d9ae9ec5f3b8d23c43";
    hash = "sha256-/hopwNR5blDo2/GHrbEetKrh1Xm4uqnDb0mPtxllW9k=";
  };

  node-pty = callPackage "${src}/nix/node-pty.nix" { };
in
callPackage "${src}/nix/claude-desktop.nix" {
  inherit node-pty;
}
