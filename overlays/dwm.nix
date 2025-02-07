self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-0000000000000000000000000000000000000000000=";
    };
  });
}
