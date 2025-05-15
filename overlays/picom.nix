self: super: {
  picom = super.picom.overrideAttrs (oldAttrs: {
    src = super.fetchFromGitHub {
      owner = "fdev31";
      repo = "picom";
      rev = "refs/heads/simpleanims";
      sha256 = "sha256-LqQOeRcY1bf5VK/wjwSocWylGB3CV/z6v36mhWZQ7Vc=";
      fetchSubmodules = true;
    };
    # 禁用文档构建以避免 a2x 依赖
    mesonFlags = (oldAttrs.mesonFlags or [ ]) ++ [
      "-Dwith_docs=false"
    ];
    # 禁用版本检查
    doInstallCheck = false;
  });
}
