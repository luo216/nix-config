{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "aaddrick";
    repo = "claude-desktop-debian";
    rev = "d50e5c366ec958bfe8325ea867c4c7ee5d2c410a";
    hash = "sha256-M1CZhiDjNKC/OYLW4xCmSxEkvTbIlKiiZwIoyahlKJg=";
  };

  node-pty = callPackage "${src}/nix/node-pty.nix" { };

  claude-desktop-unwrapped = callPackage "${src}/nix/claude-desktop.nix" {
    inherit node-pty;
  };
in
claude-desktop-unwrapped
