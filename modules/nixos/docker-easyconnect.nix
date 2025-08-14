{
  config,
  lib,
  ...
}:

let
  cfg = config.services.docker-easyconnect;

  mkPort = host: container: "${cfg.bindAddress}:${toString host}:${toString container}";

  proxyPorts = [
    (mkPort cfg.socksPort 1080)
    (mkPort cfg.httpPort 8888)
    (mkPort cfg.vncPort 5901)
  ];
in
{
  options.services.docker-easyconnect = {
    enable = lib.mkEnableOption "docker-easyconnect proxy container";

    mode = lib.mkOption {
      type = lib.types.enum [
        "proxy"
        "gateway"
      ];
      default = "proxy";
      description = ''
        Container networking mode.
        `proxy` exposes SOCKS5/HTTP/VNC on host ports.
        `gateway` uses Docker host networking so EasyConnect creates tun/routes
        in the host network namespace.
      '';
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "hagb/docker-easyconnect:7.6.7";
      description = "Container image for docker-easyconnect.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address used for exposed ports.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/docker-easyconnect";
      description = "Persistent state directory mounted to /root in the container.";
    };

    vncPassword = lib.mkOption {
      type = lib.types.str;
      default = "change-me";
      description = "VNC password for the EasyConnect desktop session.";
    };

    socksPort = lib.mkOption {
      type = lib.types.port;
      default = 21080;
      description = "Host SOCKS5 proxy port.";
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 28888;
      description = "Host HTTP proxy port.";
    };

    vncPort = lib.mkOption {
      type = lib.types.port;
      default = 25901;
      description = "Host VNC port used to log in to EasyConnect.";
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optionals (
      cfg.mode == "gateway" && (
        cfg.bindAddress != "127.0.0.1" ||
        cfg.socksPort != 21080 ||
        cfg.httpPort != 28888 ||
        cfg.vncPort != 25901
      )
    ) [
      "services.docker-easyconnect.mode = \"gateway\" uses Docker host networking; bindAddress/socksPort/httpPort/vncPort are ignored. Connect VNC to 127.0.0.1:5901, SOCKS5 to 127.0.0.1:1080, and HTTP proxy to 127.0.0.1:8888."
    ];

    virtualisation.oci-containers.backend = "docker";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root - -"
    ];

    virtualisation.oci-containers.containers.docker-easyconnect = {
      image = cfg.image;
      autoStart = true;
      # proxy mode:
      # 127.0.0.1:${toString cfg.socksPort} SOCKS5 proxy
      # 127.0.0.1:${toString cfg.httpPort} HTTP proxy
      # 127.0.0.1:${toString cfg.vncPort} VNC login session
      #
      # gateway mode:
      # Docker host networking is used, so EasyConnect tun/routes are created
      # in the host network namespace and the host sees the native ports:
      # 127.0.0.1:1080 SOCKS5, 127.0.0.1:8888 HTTP, 127.0.0.1:5901 VNC.
      ports = lib.optionals (cfg.mode == "proxy") proxyPorts;
      volumes = [
        "${cfg.dataDir}:/root"
      ];
      environment = {
        PASSWORD = cfg.vncPassword;
        URLWIN = "1";
      };
      extraOptions = [
        "--device=/dev/net/tun"
        "--cap-add=NET_ADMIN"
      ] ++ lib.optionals (cfg.mode == "gateway") [
        "--network=host"
      ];
    };
  };
}
