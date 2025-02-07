self: super: {
  dwm = super.dwm.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-pYZ4Fr+RTRxdkdquDi1ZKsdNt/iDBiL4sVB+aK0cMeo=";
    };
  });
}
