self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-7Z5Kns1M1L6hiRPhOcyI5286pAaH1DXptzSxaaPehFI=";
    };
  });
}
