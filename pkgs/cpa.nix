{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cpa";
  version = "6.9.30";

  src =
    let
      assets = {
        x86_64-linux = {
          url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
          hash = "sha256-Y5uSfuRmaW2dRMb+4aRQaJMp7WUWs91eSgi7zABhL3A=";
        };
        aarch64-linux = {
          url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_arm64.tar.gz";
          hash = "sha256-r5h3jCU8Jehs/gQml9RoR5d/w/DbNsrGh1i6HVpTiWg=";
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
