{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ccx";
  version = "2.8.20";

  src = fetchurl {
    url = "https://github.com/BenedictKing/ccx/releases/download/v${version}/ccx-linux-amd64";
    hash = "sha256-nzw6ViXBQuC0ZypRY33TZDP0GK9m4SnGJ+0e7SnqQbU=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/ccx
    runHook postInstall
  '';

  meta = with lib; {
    description = "Open-source AI API proxy & protocol-translation gateway with embedded web admin UI";
    homepage = "https://github.com/BenedictKing/ccx";
    license = licenses.mit;
    mainProgram = "ccx";
    platforms = platforms.linux;
  };
}
