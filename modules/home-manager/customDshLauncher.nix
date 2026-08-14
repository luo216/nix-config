{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.customDshLauncher;
  homeDirectory = config.home.homeDirectory;
in {
  options.services.customDshLauncher = {
    enable = lib.mkEnableOption "dsh web systemd user launcher";

    nodePackage = lib.mkOption {
      type = lib.types.package;
      # dsh's HMR service needs access to Node internals. The bundled native
      # addon (node-addon-require-builtin) fails to probe nixpkgs-built Node
      # (both 22 and 24), so `--expose-internals` is required for HMR. We pass
      # it explicitly and default to the LTS Node 22.
      default = pkgs.nodejs_22;
      defaultText = "pkgs.nodejs_22";
      description = "Node.js package used to launch dsh web.";
    };

    npmPrefix = lib.mkOption {
      type = lib.types.str;
      default = "${homeDirectory}/.npm-global";
      defaultText = "$HOME/.npm-global";
      description = "External npm prefix containing the dsh installation.";
    };

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = homeDirectory;
      defaultText = "$HOME";
      description = "Working directory used as dsh's default workspace root.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Only manage the launcher. The dsh npm package remains external.
    systemd.user.services.dsh-web = {
      Unit = {
        Description = "dsh web (DeepSeek Harness browser UI)";
        Documentation = "https://github.com/deepseek-ai/deepseek-harness";
        Wants = ["network-online.target"];
        After = ["network-online.target"];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = cfg.workingDirectory;
        Environment = [
          "HOME=${homeDirectory}"
          "PATH=${cfg.npmPrefix}/bin:${lib.makeBinPath [cfg.nodePackage]}:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
        ];
        ExecStart = "${cfg.nodePackage}/bin/node --expose-internals ${cfg.npmPrefix}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js web";
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
