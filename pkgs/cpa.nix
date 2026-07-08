{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cpa";
  version = "7.2.53";

  src =
    let
      assets = {
        x86_64-linux = {
          url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
          hash = "sha256-WSMapHGWtnG8wVAd6p0qOGo2x1sRC76AQuTKNbGP4Tg=";
        };
        aarch64-linux = {
          url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_arm64.tar.gz";
          hash = "sha256-mxY8+vAholjKr7V3zcRH/TNuMHkr5I52bTJ0bKC53dQ=";
        };
      };
      asset =
        assets.${stdenvNoCC.hostPlatform.system}
          or (throw "cpa: unsupported system ${stdenvNoCC.hostPlatform.system}");
    in
    fetchurl {
      inherit (asset) url hash;
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
    platforms = platforms.linux;
  };
}
