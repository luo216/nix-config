{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cpa";
  version = "8.0.13";

  src = fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
    hash = "sha256-UOz/tH/dgcjFqYJac6epBatmNCM34nTznEJ2uS01M/M=";
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 cli-proxy-api "$out/bin/cpa"
    ln -s "$out/bin/cpa" "$out/bin/cliproxyapi"
    install -Dm644 config.example.yaml "$out/share/doc/cpa/config.example.yaml"
    install -Dm644 README.md "$out/share/doc/cpa/README.md"
  '';

  meta = with lib; {
    description = "OpenAI/Gemini/Claude/Codex compatible API proxy for CLI tools";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    mainProgram = "cpa";
    platforms = ["x86_64-linux"];
  };
}
