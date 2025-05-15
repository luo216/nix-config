self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-QgqDhB9GkkzR66Bs1CiFHdMRTtXZsJAbe6FZssG6FN0=";
    };
  });
}
