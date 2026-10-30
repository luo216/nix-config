# vps/root — headless service host; keep minimal, no desktop-ish modules.
{
  outputs,
  pkgs,
  user,
  ...
}: {
  home = {
    inherit (user) username;
    homeDirectory = "/root";
    stateVersion = "25.11";

    packages = with pkgs; [
      curl
      jq
      htop
      vim
    ];
  };

  programs = {
    git.enable = true;
  };
}
