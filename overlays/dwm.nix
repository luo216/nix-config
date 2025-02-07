self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-EMC6D+v6iqRuz7gTB33YbDuLiLhx+p/aAwFtk75fXwY==";
    };
  });
}
