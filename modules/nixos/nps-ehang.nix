{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.nps-ehang;

  inherit
    (lib)
    concatStringsSep
    escapeShellArg
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    types
    ;

  stateBinDir = "${cfg.dataDir}/bin";
  stateConfDir = "${stateBinDir}/conf";
  stateWebDir = "${stateBinDir}/web";
  secretsDir = "${cfg.dataDir}/secrets";

  portOrBlank = port:
    if port == null
    then ""
    else toString port;
  allowPortsValue =
    if cfg.allowPorts == []
    then ""
    else concatStringsSep "," cfg.allowPorts;
in {
  options.services.nps-ehang = {
    enable = mkEnableOption "ehang-io nps server";

    package = mkOption {
      type = types.package;
      default = pkgs.nps-ehang;
      defaultText = literalExpression "pkgs.nps-ehang";
      description = "Package providing the nps and npc binaries.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/nps-ehang";
      description = "Writable state directory for nps runtime data and generated config.";
    };

    user = mkOption {
      type = types.str;
      default = "nps";
      description = "System user used by the nps service.";
    };

    group = mkOption {
      type = types.str;
      default = "nps";
      description = "System group used by the nps service.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open configured nps ports in the NixOS firewall.";
    };

    bridgeIp = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Bridge listener address.";
    };

    bridgePort = mkOption {
      type = types.port;
      default = 8024;
      description = "Bridge listener port used by npc clients.";
    };

    webIp = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Web UI listener address.";
    };

    webPort = mkOption {
      type = types.nullOr types.port;
      default = 8080;
      description = "Web UI listener port. Set to null to disable the web UI.";
    };

    webHost = mkOption {
      type = types.str;
      default = "localhost";
      description = "Host name used when nps multiplexes services onto one port.";
    };

    httpProxyIp = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "HTTP proxy listener address.";
    };

    httpProxyPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "HTTP proxy listener port. Set to null to disable.";
    };

    httpsProxyPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "HTTPS proxy listener port. Set to null to disable.";
    };

    httpsJustProxy = mkOption {
      type = types.bool;
      default = true;
      description = "Forward HTTPS traffic directly instead of terminating TLS in nps.";
    };

    adminUsername = mkOption {
      type = types.str;
      default = "admin";
      description = "Admin username for the nps web UI.";
    };

    adminPassword = mkOption {
      type = types.str;
      default = "passwd";
      description = "Admin password for the nps web UI.";
    };

    publicVkey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional global shared vkey. Leave null to require per-client vkeys from the web UI.";
    };

    allowPorts = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["9001-9009" "10001" "11000-12000"];
      description = "Optional allowlist for ports that clients may expose.";
    };

    logLevel = mkOption {
      type = types.int;
      default = 4;
      description = "nps log level from 0 to 7.";
    };

    disconnectTimeout = mkOption {
      type = types.int;
      default = 60;
      description = "Client disconnect timeout in seconds.";
    };

    allowUserLogin = mkOption {
      type = types.bool;
      default = false;
      description = "Allow per-client web UI logins.";
    };

    allowUserRegister = mkOption {
      type = types.bool;
      default = false;
      description = "Allow self-service user registration.";
    };

    allowUserChangeUsername = mkOption {
      type = types.bool;
      default = false;
      description = "Allow users to change their usernames in the web UI.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra lines appended to the generated nps.conf.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    users.users = mkIf (cfg.user == "nps") {
      nps = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == "nps") {
      nps = {};
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall (
      [
        cfg.bridgePort
      ]
      ++ optional (cfg.webPort != null) cfg.webPort
      ++ optional (cfg.httpProxyPort != null) cfg.httpProxyPort
      ++ optional (cfg.httpsProxyPort != null) cfg.httpsProxyPort
    );

    systemd.services.nps-ehang = {
      description = "ehang-io nps server";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
      ];
      wants = [
        "network-online.target"
      ];
      path = with pkgs; [
        coreutils
        openssl
        rsync
      ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${stateBinDir}/nps";
        Restart = "on-failure";
        RestartSec = 5;
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
        NoNewPrivileges = true;
      };
      preStart = ''
                        umask 077

                        mkdir -p ${escapeShellArg cfg.dataDir} \
                          ${escapeShellArg stateBinDir} \
                          ${escapeShellArg stateConfDir} \
                          ${escapeShellArg stateWebDir} \
                          ${escapeShellArg secretsDir}

                        ln -sfn ${escapeShellArg "${cfg.package}/bin/nps"} ${escapeShellArg "${stateBinDir}/nps"}
                        ln -sfn ${escapeShellArg "${cfg.package}/bin/npc"} ${escapeShellArg "${stateBinDir}/npc"}

                        rsync -a --delete ${escapeShellArg "${cfg.package}/share/nps/web/"} ${escapeShellArg "${stateWebDir}/"}

                        if [ ! -e ${escapeShellArg "${stateConfDir}/clients.json"} ]; then
                          cp ${escapeShellArg "${cfg.package}/share/nps/conf/clients.json"} ${escapeShellArg "${stateConfDir}/clients.json"}
                        fi

                        if [ ! -e ${escapeShellArg "${stateConfDir}/hosts.json"} ]; then
                          cp ${escapeShellArg "${cfg.package}/share/nps/conf/hosts.json"} ${escapeShellArg "${stateConfDir}/hosts.json"}
                        fi

                        if [ ! -e ${escapeShellArg "${stateConfDir}/tasks.json"} ]; then
                          cp ${escapeShellArg "${cfg.package}/share/nps/conf/tasks.json"} ${escapeShellArg "${stateConfDir}/tasks.json"}
                        fi

                if [ ! -s ${escapeShellArg "${secretsDir}/auth_crypt_key"} ]; then
                  openssl rand -hex 8 > ${escapeShellArg "${secretsDir}/auth_crypt_key"}
                fi

                auth_crypt_key="$(tr -d '\n' < ${escapeShellArg "${secretsDir}/auth_crypt_key"} | cut -c1-16)"

        {
          printf '%s\n' 'appname = nps'
          printf '%s\n' 'runmode = pro'
          printf '%s\n' 'http_proxy_ip=${cfg.httpProxyIp}'
          printf '%s\n' 'http_proxy_port=${portOrBlank cfg.httpProxyPort}'
          printf '%s\n' 'https_proxy_port=${portOrBlank cfg.httpsProxyPort}'
          printf '%s\n' 'https_just_proxy=${
          if cfg.httpsJustProxy
          then "true"
          else "false"
        }'
          printf '%s\n' 'bridge_type=tcp'
          printf '%s\n' 'bridge_port=${toString cfg.bridgePort}'
          printf '%s\n' 'bridge_ip=${cfg.bridgeIp}'
          printf '%s\n' 'public_vkey=${
          if cfg.publicVkey == null
          then ""
          else cfg.publicVkey
        }'
          printf '%s\n' 'log_level=${toString cfg.logLevel}'
          printf '%s\n' 'log_path=${cfg.dataDir}/nps.log'
          printf '%s\n' 'web_host=${cfg.webHost}'
          printf '%s\n' 'web_username=${cfg.adminUsername}'
          printf '%s\n' 'web_password=${cfg.adminPassword}'
          printf '%s\n' 'web_port = ${portOrBlank cfg.webPort}'
          printf '%s\n' 'web_ip=${cfg.webIp}'
          printf '%s\n' 'web_base_url='
          printf '%s\n' 'web_open_ssl=false'
          printf 'auth_crypt_key=%s\n' "$auth_crypt_key"
          printf '%s\n' 'allow_ports=${allowPortsValue}'
          printf '%s\n' 'allow_user_login=${
          if cfg.allowUserLogin
          then "true"
          else "false"
        }'
          printf '%s\n' 'allow_user_register=${
          if cfg.allowUserRegister
          then "true"
          else "false"
        }'
          printf '%s\n' 'allow_user_change_username=${
          if cfg.allowUserChangeUsername
          then "true"
          else "false"
        }'
          printf '%s\n' 'disconnect_timeout=${toString cfg.disconnectTimeout}'
          ${optionalString (cfg.extraConfig != "") "printf '%s\n' ${escapeShellArg cfg.extraConfig}"}
        } > ${escapeShellArg "${stateConfDir}/nps.conf"}
      '';
    };
  };
}
