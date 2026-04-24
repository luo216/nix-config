{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.customCpa;
  configFile = "${config.xdg.configHome}/cpa/config.yaml";
  initialConfig =
    let
      managementLines =
        if cfg.managementSecretKey == null then
          [
            "remote-management:"
            "  allow-remote: ${if cfg.allowRemoteManagement then "true" else "false"}"
            "  secret-key: \"\""
            "  disable-control-panel: false"
            "  panel-github-repository: \"https://github.com/router-for-me/Cli-Proxy-API-Management-Center\""
          ]
        else
          [
            "remote-management:"
            "  allow-remote: ${if cfg.allowRemoteManagement then "true" else "false"}"
            "  secret-key: ${builtins.toJSON cfg.managementSecretKey}"
            "  disable-control-panel: false"
            "  panel-github-repository: \"https://github.com/router-for-me/Cli-Proxy-API-Management-Center\""
          ];
    in
    lib.concatStringsSep "\n" (
      [
        "host: ${builtins.toJSON cfg.host}"
        "port: ${toString cfg.port}"
      ]
      ++ managementLines
      ++ [
        "auth-dir: ${builtins.toJSON cfg.authDir}"
        "api-keys:"
      ]
      ++ map (key: "  - ${builtins.toJSON key}") cfg.apiKeys
      ++ [
        "debug: false"
        "usage-statistics-enabled: ${if cfg.usageStatisticsEnabled then "true" else "false"}"
        ""
      ]
    );
in
{
  options.services.customCpa = with lib; {
    enable = mkEnableOption "CLIProxyAPI user service";

    package = mkOption {
      type = types.package;
      default = pkgs.cpa;
      defaultText = "pkgs.cpa";
      description = "CLIProxyAPI package to run.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host interface for the local proxy.";
    };

    port = mkOption {
      type = types.port;
      default = 8317;
      description = "Listening port for the local proxy.";
    };

    apiKeys = mkOption {
      type = types.listOf types.str;
      default = [ "change-me" ];
      description = "Client API keys accepted by CLIProxyAPI.";
    };

    managementSecretKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional management API secret. Null disables management routes.";
    };

    allowRemoteManagement = mkOption {
      type = types.bool;
      default = false;
      description = "Whether CPA management endpoints may be accessed from non-localhost clients.";
    };

    authDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/cpa/auth";
      description = "Directory for CLIProxyAPI auth/token files.";
    };

    usageStatisticsEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "Whether CLIProxyAPI aggregates usage statistics for the management panel.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.cpaBootstrapConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      config_dir="${config.xdg.configHome}/cpa"
      config_file="${configFile}"
      mkdir -p "$config_dir"

      if [ ! -e "$config_file" ]; then
        cat > "$config_file" <<'EOF'
${initialConfig}
EOF
      fi
    '';

    systemd.user.services.cpa = {
      Unit = {
        Description = "CLIProxyAPI";
        After = [ "network.target" ];
      };

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.authDir}";
        ExecStart = "${cfg.package}/bin/cpa -config ${configFile}";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
