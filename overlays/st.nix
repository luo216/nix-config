self: super: {
  st = super.st.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "luo216";
      repo = "st";
      rev = "master";
      sha256 = "sha256-m7TXB1S8S7lR6WZIgg5pt/ueFzKdmJ1gEAgLuPf/Vks=";
    };
  });
}
