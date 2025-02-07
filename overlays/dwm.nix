self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-8IgXjg11/K1R5S3E9BZNm4qtyuoqBooGXGQmC3cjVSQ=";
    };
  });
}
