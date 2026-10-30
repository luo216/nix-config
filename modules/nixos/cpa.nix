{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cpa;

  inherit
    (lib)
    escapeShellArg
    getExe
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;

  # Bootstrap config: only written when none exists yet, so edits made via the
  # management panel or by hand survive restarts and redeployments.
  initialConfig = pkgs.writeText "cpa-config.yaml" (
    lib.concatStringsSep "\n"
    (
      [
        "host: ${builtins.toJSON cfg.host}"
        "port: ${toString cfg.port}"
        "remote-management:"
        "  allow-remote: false"
        "  secret-key: ${builtins.toJSON (cfg.managementSecretKey or "")}"
        "  disable-control-panel: false"
        "  panel-github-repository: \"https://github.com/router-for-me/Cli-Proxy-API-Management-Center\""
        "auth-dir: ${builtins.toJSON cfg.authDir}"
        "api-keys:"
      ]
      ++ map (key: "  - ${builtins.toJSON key}") cfg.apiKeys
      ++ [
        "debug: false"
        "usage-statistics-enabled: true"
        ""
      ]
    )
  );

  initScript = pkgs.writeShellScript "cpa-init" ''
    set -eu
    umask 077
    mkdir -p ${escapeShellArg cfg.authDir} ${escapeShellArg cfg.configDir}
    if [ ! -e ${escapeShellArg cfg.configFile} ]; then
      install -m 600 ${initialConfig} ${escapeShellArg cfg.configFile}
    fi
  '';
in {
  options.services.cpa = {
    enable = mkEnableOption "CLIProxyAPI (cpa) OpenAI-compatible proxy";

    package = mkOption {
      type = types.package;
      default = pkgs.cpa;
      defaultText = literalExpression "pkgs.cpa";
      description = "Package providing the cpa binary.";
    };

    user = mkOption {
      type = types.str;
      default = "cpa";
      description = "System user used by the service.";
    };

    group = mkOption {
      type = types.str;
      default = "cpa";
      description = "System group used by the service.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/cpa";
      description = "Writable state directory holding config.yaml and auth files.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address. Keep loopback unless exposed through a tunnel.";
    };

    port = mkOption {
      type = types.port;
      default = 8317;
      description = "Listen port.";
    };

    apiKeys = mkOption {
      type = types.listOf types.str;
      default = ["change-me"];
      description = "Client API keys accepted by the proxy. Written only on first start.";
    };

    managementSecretKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Management API secret. Written only on first start; null leaves it empty.";
    };

    authDir = mkOption {
      type = types.str;
      default = "/var/lib/cpa/auth";
      description = "Directory for CLIProxyAPI auth/token files.";
    };

    configDir = mkOption {
      type = types.str;
      default = "/var/lib/cpa";
      description = "Directory holding config.yaml.";
    };

    configFile = mkOption {
      type = types.str;
      default = "/var/lib/cpa/config.yaml";
      description = "Path of the bootstrap-written config file.";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "cpa") {
      cpa = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "cpa") {
      cpa = {};
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.authDir} 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.cpa = {
      description = "CLIProxyAPI OpenAI-compatible proxy";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStartPre = initScript;
        ExecStart = "${getExe cfg.package} -config ${cfg.configFile}";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ReadWritePaths = [cfg.dataDir];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        CapabilityBoundingSet = [];
        AmbientCapabilities = [];
      };
    };
  };
}
