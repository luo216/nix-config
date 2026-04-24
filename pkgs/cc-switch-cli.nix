{ lib, fetchurl, stdenvNoCC }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cc-switch-cli";
  version = "5.3.4";

  src = fetchurl {
    url = "https://github.com/SaladDay/cc-switch-cli/releases/download/v${finalAttrs.version}/cc-switch-cli-linux-x64-musl.tar.gz";
    hash = "sha256-v/A2c8UfOcaUfBTouHIqsHh0zpGJfIx9+WCx8DN1HKA=";
  };

  dontConfigure = true;
  dontBuild = true;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 cc-switch "$out/bin/cc-switch"
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI management tool for Claude Code, Codex, Gemini, OpenCode and OpenClaw";
    homepage = "https://github.com/SaladDay/cc-switch-cli";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "cc-switch";
  };
})
