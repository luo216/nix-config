{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.customPiWebLauncher;
  homeDirectory = config.home.homeDirectory;
in {
  options.services.customPiWebLauncher = {
    enable = lib.mkEnableOption "pi-web systemd user launcher";

    nodePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs_24;
      defaultText = "pkgs.nodejs_24";
      description = "Node.js package used to launch pi-web.";
    };

    npmPrefix = lib.mkOption {
      type = lib.types.str;
      default = "${homeDirectory}/.npm-global";
      defaultText = "$HOME/.npm-global";
      description = "External npm prefix containing the pi-web installation.";
    };

    agentDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDirectory}/.pi/agent";
      defaultText = "$HOME/.pi/agent";
      description = "Pi Coding Agent data directory exposed to pi-web.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which pi-web listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Only manage the launcher. The pi-web npm package remains external.
    systemd.user.services.pi-web = {
      Unit = {
        Description = "Pi Web UI for Pi Coding Agent";
        Documentation = "https://github.com/agegr/pi-web";
        Wants = ["network-online.target"];
        After = ["network-online.target"];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = homeDirectory;
        Environment = [
          "HOME=${homeDirectory}"
          "PI_CODING_AGENT_DIR=${cfg.agentDir}"
          "PATH=${cfg.npmPrefix}/bin:${lib.makeBinPath [cfg.nodePackage]}:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
        ];
        ExecStart = "${cfg.nodePackage}/bin/node ${cfg.npmPrefix}/lib/node_modules/@agegr/pi-web/bin/pi-web.js --hostname ${cfg.listenAddress} --no-open";
        Restart = "on-failure";
        RestartSec = 3;
        KillMode = "control-group";
        KillSignal = "SIGINT";
        TimeoutStopSec = 10;
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
