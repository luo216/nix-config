{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.workbuddy2api;

  inherit
    (lib)
    escapeShellArgs
    getExe
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  logFile =
    if cfg.logFile != null
    then cfg.logFile
    else "${cfg.dataDir}/proxy.jsonl";

  startArgs =
    [
      "--host"
      cfg.host
      "--port"
      (toString cfg.port)
      "--accounts-dir"
      "${cfg.dataDir}/accounts"
      "--log-file"
      logFile
      "--no-browser"
    ]
    ++ cfg.extraArgs;
in {
  options.services.workbuddy2api = {
    enable = mkEnableOption "workbuddy2api OpenAI/Anthropic-compatible gateway";

    package = mkOption {
      type = types.package;
      default = pkgs.workbuddy2api;
      defaultText = literalExpression "pkgs.workbuddy2api";
      description = "Package providing the workbuddy2api executable.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/workbuddy2api";
      description = "Writable state directory holding the account store and logs.";
    };

    user = mkOption {
      type = types.str;
      default = "workbuddy2api";
      description = "System user used by the service.";
    };

    group = mkOption {
      type = types.str;
      default = "workbuddy2api";
      description = "System group used by the service.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address for the API and the /admin panel.";
    };

    port = mkOption {
      type = types.port;
      default = 7863;
      description = "Port for the OpenAI/Anthropic API and the /admin panel.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the configured port in the NixOS firewall.";
    };

    logFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "JSONL request log path. Defaults to <dataDir>/proxy.jsonl.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra command-line arguments passed to workbuddy2api.";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "workbuddy2api") {
      workbuddy2api = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "workbuddy2api") {
      workbuddy2api = {};
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/accounts 0700 ${cfg.user} ${cfg.group} -"
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];

    systemd.services.workbuddy2api = {
      description = "workbuddy2api OpenAI/Anthropic-compatible gateway";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${getExe cfg.package} ${escapeShellArgs startArgs}";
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

      environment = {
        # Upstream calls use urllib; NixOS only ships the CA bundle, not the
        # hashed certificate directory, so point Python at the bundle.
        SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
        HOME = cfg.dataDir;
        PYTHONUNBUFFERED = "1";
      };
    };
  };
}
