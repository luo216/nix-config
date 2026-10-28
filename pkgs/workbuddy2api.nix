{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "workbuddy2api";
  version = "unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "linguo2625469";
    repo = "workbuddy2api-panel";
    rev = "73a7560efc7a88ebd9865db4c71ae7f6d85859f8";
    hash = "sha256-z36HsTqacJeD/S2NV2+wof/YUUxulR9sKEsc6lC1WPI=";
  };

  vendorHash = "sha256-lU0Lysa7w2v8Hyhj1u94UvHeezieHQP8LnN5hNO/6C4=";

  subPackages = ["cmd/server"];

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/server $out/bin/wb2api
  '';

  meta = with lib; {
    description = "OpenAI-compatible gateway for Tencent CodeBuddy accounts, with a web panel";
    homepage = "https://github.com/linguo2625469/workbuddy2api-panel";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "wb2api";
  };
}
