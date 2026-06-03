{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.programs.customHermes;
  inherit (inputs) hermes-agent;

  system = pkgs.stdenv.hostPlatform.system;
  hermesAgentPkg = hermes-agent.packages.${system}.default;

  # Resolve hermes-agent's bundled Python at build time
  hermesPython = builtins.head (
    builtins.match ".*HERMES_PYTHON='([^']+)'.*"
      (builtins.readFile "${hermesAgentPkg}/bin/hermes")
  );

  hermesWebui = pkgs.stdenv.mkDerivation {
    pname = "hermes-webui";
    version = "0.51.223";

    src = pkgs.fetchFromGitHub {
      owner = "nesquena";
      repo = "hermes-webui";
      rev = "v0.51.223";
      hash = "sha256-UNMB4Bj+Q1UY3BqgCswguQgbHK+Iy9dLipzKzOsFNKI=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/hermes-webui $out/bin
      cp -r api static server.py $out/share/hermes-webui/
      makeWrapper ${hermesPython} $out/bin/hermes-webui \
        --add-flags "$out/share/hermes-webui/server.py" \
        --prefix PATH : ${lib.makeBinPath [ hermesAgentPkg ]} \
        --set-default HERMES_WEBUI_HOST "127.0.0.1" \
        --set-default HERMES_WEBUI_PORT "8787"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Web UI for Hermes Agent — chat, sessions, skills, memory, cron, workspace";
      homepage = "https://github.com/nesquena/hermes-webui";
      license = licenses.mit;
      platforms = platforms.linux ++ platforms.darwin;
      mainProgram = "hermes-webui";
    };
  };
in
{
  options.programs.customHermes = with lib; {
    enable = mkEnableOption "Hermes Agent (official CLI) and Web UI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      hermesAgentPkg
      hermesWebui
    ];

    systemd.user.services.hermes-webui = {
      Unit = {
        Description = "Hermes Agent Web UI";
        Documentation = "https://github.com/nesquena/hermes-webui";
        After = [ "network.target" ];
        Wants = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${hermesWebui}/bin/hermes-webui";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = ''
          HERMES_WEBUI_HOST=127.0.0.1
          HERMES_WEBUI_PORT=8787
        '';
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
