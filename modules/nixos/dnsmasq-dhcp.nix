{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.dnsmasq-dhcp;
in
{
  options.services.dnsmasq-dhcp = {
    enable = mkEnableOption "dnsmasq DHCP server for device provisioning";

    interface = mkOption {
      type = types.str;
      description = "Network interface to serve DHCP on";
    };

    subnet = mkOption {
      type = types.str;
      default = "192.168.99";
      description = "Subnet prefix (e.g. 192.168.99 → 192.168.99.0/24)";
    };

    hostIP = mkOption {
      type = types.int;
      default = 1;
      description = "This machine's IP (last octet)";
    };

    poolStart = mkOption {
      type = types.int;
      default = 100;
      description = "DHCP pool start (last octet)";
    };

    poolEnd = mkOption {
      type = types.int;
      default = 200;
      description = "DHCP pool end (last octet)";
    };

    dns = mkOption {
      type = types.str;
      default = "8.8.8.8";
      description = "DNS server for clients";
    };

    staticBindings = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            mac = mkOption { type = types.str; };
            ip = mkOption { type = types.str; };
          };
        }
      );
      default = [ ];
      description = "Static MAC→IP bindings";
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces.${cfg.interface}.ipv4.addresses = [
      {
        address = "${cfg.subnet}.${toString cfg.hostIP}";
        prefixLength = 24;
      }
    ];

    networking.networkmanager.unmanaged = [ cfg.interface ];

    services.dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      resolveLocalQueries = false;
      settings = {
        interface = cfg.interface;
        bind-interfaces = true;
        dhcp-range = [ "${cfg.subnet}.${toString cfg.poolStart},${cfg.subnet}.${toString cfg.poolEnd},24h" ];
        dhcp-option = [
          "option:router,${cfg.subnet}.${toString cfg.hostIP}"
          "option:dns-server,${cfg.dns}"
        ];
        dhcp-host = map (b: "${b.mac},${b.ip},${b.name}") cfg.staticBindings;
        log-dhcp = true;
      };
    };
  };
}
