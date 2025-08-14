{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cpa";
  version = "7.3.7";

  src = fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
    hash = "sha256-M5Hf9nKrzP/OX5JZt84eEs7nsKiqP1sigEBkhPWfN7o=";
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
    platforms = [ "x86_64-linux" ];
  };
}
