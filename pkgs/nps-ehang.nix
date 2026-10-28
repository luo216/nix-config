{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "nps-ehang";
  version = "unstable-2026-07-05";
  rev = "ab648d6f0c618c690a7a79948a7ebd686e1cdafc";

  src = fetchFromGitHub {
    owner = "ehang-io";
    repo = "nps";
    inherit rev;
    hash = "sha256-xsc8FvAT+r9lyeLjDylkCcfQaQowH5V2S4/PT7Ayg9o=";
  };

  vendorHash = "sha256-iYfCzsL+MwO8L2/rh9A/9oLcY/WZq7hS1FKZi8KjNzM=";

  subPackages = [
    "cmd/nps"
    "cmd/npc"
  ];

  postPatch = ''
    rm -f cmd/npc/sdk.go
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mkdir -p $out/share/nps/conf $out/share/nps/web
    cp conf/{clients.json,hosts.json,multi_account.conf,npc.conf,nps.conf,server.key,server.pem,tasks.json} $out/share/nps/conf/
    cp -r web/static web/views $out/share/nps/web/
  '';

  meta = with lib; {
    description = "Lightweight intranet penetration proxy server from ehang-io";
    homepage = "https://github.com/ehang-io/nps";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "nps";
  };
}
