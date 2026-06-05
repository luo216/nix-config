{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.customCcx;

  mkEnvFlag = name: value: "-e ${name}=${lib.escapeShellArg value}";

  envFlags =
    [
      (mkEnvFlag "PROXY_ACCESS_KEY" cfg.proxyAccessKey)
      (mkEnvFlag "APP_UI_LANGUAGE" cfg.appUiLanguage)
      (mkEnvFlag "LOG_LEVEL" cfg.logLevel)
      (mkEnvFlag "REQUEST_TIMEOUT" (toString cfg.requestTimeout))
      (mkEnvFlag "ENABLE_REQUEST_LOGS" (if cfg.enableRequestLogs then "true" else "false"))
      (mkEnvFlag "ENABLE_RESPONSE_LOGS" (if cfg.enableResponseLogs then "true" else "false"))
    ]
    ++ lib.optional (cfg.adminAccessKey != null) (mkEnvFlag "ADMIN_ACCESS_KEY" cfg.adminAccessKey)
    ++ lib.mapAttrsToList mkEnvFlag cfg.extraEnv;
in
{
  options.services.customCcx = with lib; {
    enable = mkEnableOption "CCX — AI API proxy & protocol-translation gateway (Docker container)";

    image = mkOption {
      type = types.str;
      default = "crpi-i19l8zl0ugidq97v.cn-hangzhou.personal.cr.aliyuncs.com/bene/ccx:latest";
      description = "Docker image for CCX.";
    };

    port = mkOption {
      type = types.port;
      default = 3688;
      description = "Host port to map to container port 3000.";
    };

    proxyAccessKey = mkOption {
      type = types.str;
      default = "change-me";
      description = "PROXY_ACCESS_KEY — client API key to access the unified AI proxy endpoint.";
    };

    adminAccessKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "ADMIN_ACCESS_KEY — optional admin secret for the web management panel.";
    };

    appUiLanguage = mkOption {
      type = types.enum [ "en" "zh" ];
      default = "zh";
      description = "Web UI language (en / zh).";
    };

    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "Log verbosity level.";
    };

    requestTimeout = mkOption {
      type = types.int;
      default = 300000;
      description = "HTTP request timeout in milliseconds.";
    };

    enableRequestLogs = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to log HTTP requests. Keep off unless debugging.";
    };

    enableResponseLogs = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to log full HTTP response bodies. Keep off in production — generates massive logs.";
    };

    configDir = mkOption {
      type = types.str;
      default = "$HOME/.config/ccx";
      description = "Host directory to mount as /app/.config in the container. Supports shell variables like \$HOME.";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables passed to the CCX container.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.ccx = {
      Unit = {
        Description = "CCX AI API Gateway (Docker)";
        Documentation = "https://github.com/BenedictKing/ccx";
        After = [ "network.target" ];
        Wants = [ "network.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = [
          "-${pkgs.docker}/bin/docker rm -f ccx"
        ];
        ExecStart = pkgs.writeShellScript "ccx-start" ''
          set -e
          CONFIG_DIR="${cfg.configDir}"
          mkdir -p "$CONFIG_DIR" "$CONFIG_DIR/logs"
          exec ${pkgs.docker}/bin/docker run -d \
            --name ccx \
            -p ${toString cfg.port}:3000 \
            ${lib.concatStringsSep " " envFlags} \
            -v "$CONFIG_DIR:/app/.config" \
            -v "$CONFIG_DIR/logs:/app/logs" \
            ${cfg.image}
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop ccx";
        ExecStopPost = [
          "-${pkgs.docker}/bin/docker rm ccx"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
