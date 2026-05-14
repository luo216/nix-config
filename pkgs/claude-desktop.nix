{
  callPackage,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "aaddrick";
    repo = "claude-desktop-debian";
    rev = "fa8f3441c0ea1146f2abbdbf5d39222ef5102a9e";
    hash = "sha256-W++Pf9M7FCZtaBhl6ZtBMiLV0NbBNk4/RGwfTYcjtr0=";
  };

  node-pty = callPackage "${src}/nix/node-pty.nix" { };

  claude-desktop-unwrapped = callPackage "${src}/nix/claude-desktop.nix" {
    inherit node-pty;
  };
in
callPackage "${src}/nix/fhs.nix" {
  claude-desktop = claude-desktop-unwrapped;
}
