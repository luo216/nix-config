{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.workbuddy2api;

  inherit
    (lib)
    escapeShellArg
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optionalString
    recursiveUpdate
    types
    ;

  jsonFormat = pkgs.formats.json {};

  seedConfig = jsonFormat.generate "workbuddy2api-config.json" (recursiveUpdate
    {
      listen = ":${toString cfg.port}";
      auth_dir = "./auths";
      state_file = "./data/state.json";
    }
    (optionalAttrs (cfg.apiKey != null) {api_key = cfg.apiKey;}));

  initScript = pkgs.writeShellScript "workbuddy2api-init" ''
    set -eu
    umask 077
    mkdir -p auths data
    ${optionalString (cfg.apiKey != null) ''
      if [ ! -e config.json ]; then
        install -m 600 ${seedConfig} config.json
      else
        tmp="$(mktemp .config.json.XXXXXX)"
        ${pkgs.jq}/bin/jq --arg key ${escapeShellArg cfg.apiKey} '.api_key = $key' config.json > "$tmp"
        chmod 600 "$tmp"
        mv "$tmp" config.json
      fi
    ''}
  '';
in {
  options.services.workbuddy2api = {
    enable = mkEnableOption "WorkBuddy2API OpenAI-compatible gateway";

    package = mkOption {
      type = types.package;
      default = pkgs.workbuddy2api;
      defaultText = literalExpression "pkgs.workbuddy2api";
      description = "Package providing the wb2api binary.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/workbuddy2api";
      description = "Writable state directory holding config.json, auths/, and data/.";
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

    port = mkOption {
      type = types.port;
      default = 7863;
      description = "Port opened in the firewall. The actual listen address is stored in config.json and managed from the web panel.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open the configured port in the NixOS firewall.";
    };

    apiKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Bearer key used for both the OpenAI-compatible API and the web panel.
        When set, it is written into config.json at every service start, so this
        option is authoritative over changes made in the panel. The key is part
        of the Nix store. When null, the service generates a random key on first
        start and the panel owns it.
      '';
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
      "d ${cfg.dataDir}/auths 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/data 0700 ${cfg.user} ${cfg.group} -"
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];

    systemd.services.workbuddy2api = {
      description = "WorkBuddy2API OpenAI-compatible gateway";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStartPre = initScript;
        ExecStart = "${lib.getExe cfg.package} -config ${cfg.dataDir}/config.json";
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
