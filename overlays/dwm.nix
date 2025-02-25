self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-gMLAueXbEbbimTASpf0tipG+zy6yHgAs88LLnauf+HY==";
    };
  });
}
