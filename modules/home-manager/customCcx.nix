{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.customCcx;
in
{
  options.services.customCcx = with lib; {
    enable = mkEnableOption "CCX — AI API proxy & protocol-translation gateway";

    package = mkOption {
      type = types.package;
      default = pkgs.ccx;
      defaultText = "pkgs.ccx";
      description = "CCX package to run.";
    };

    port = mkOption {
      type = types.port;
      default = 3688;
      description = "Listening port for the CCX gateway.";
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

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables passed to CCX.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.ccx = {
      Unit = {
        Description = "CCX AI API Gateway";
        Documentation = "https://github.com/BenedictKing/ccx";
        After = [ "network.target" ];
        Wants = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/ccx --statedir %h/.local/state/ccx --logdir none";
        Restart = "on-failure";
        RestartSec = 5;
        Environment =
          lib.mapAttrsToList (n: v: "${n}=${v}") (
            {
              PORT = toString cfg.port;
              PROXY_ACCESS_KEY = cfg.proxyAccessKey;
              APP_UI_LANGUAGE = cfg.appUiLanguage;
              LOG_LEVEL = cfg.logLevel;
              REQUEST_TIMEOUT = toString cfg.requestTimeout;
            }
            // lib.optionalAttrs (cfg.adminAccessKey != null) {
              ADMIN_ACCESS_KEY = cfg.adminAccessKey;
            }
            // cfg.extraEnv
          );
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
