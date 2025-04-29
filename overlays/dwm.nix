self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-s2h4WbhPHrhj1TbOS64XHGDQipFq32pLUgLUTXyD3aY=";
    };
  });
}
