# vps — headless service host behind a NAT gateway (port-forwarded public IP).
# Hardware: BIOS (SeaBIOS) + single virtio disk /dev/vda + static private net.
# Secrets are injected via outputs.secrets; runtime-mutated files live in
# /var/lib and are seeded once on first boot.
{
  config,
  lib,
  outputs,
  pkgs,
  ...
}: let
  secrets = outputs.secrets;
in {
  imports = [
    outputs.nixosModules.nps-ehang
    outputs.nixosModules.workbuddy2api
    outputs.nixosModules.cpa
  ];

  # BIOS boot: no UEFI. grub.devices is derived automatically from disko's
  # EF02 partition — do not redeclare it here.
  boot.loader = {
    grub.enable = true;
    efi.canTouchEfiVariables = lib.mkForce false;
  };

  # Static private addressing on the provider's NAT network (internal
  # addresses are non-routable). The public IP and the NAT port-mapping
  # table live in Share/config/vps/ — never hardcode them here.
  networking = {
    useDHCP = false;
    defaultGateway = "172.16.0.1";
    nameservers = [
      "223.5.5.5"
      "114.114.114.114"
    ];
    interfaces.ens17.ipv4.addresses = [
      {
        address = "172.16.0.15";
        prefixLength = 12;
      }
    ];
    firewall = {
      enable = true;
      # Public reachability goes through the provider's NAT mappings; the
      # mapping table lives in Share/config/vps/README.md, not here.
      allowedTCPPorts = [
        22 # SSH
        8024 # nps bridge
        1080 # nps tunnel port range
        1081
        8080 # nps web panel
        8317 # cpa API
      ];
    };
  };

  # International egress is blocked on this network; use domestic IPv4 NTP.
  # (These two are public pool addresses of Alibaba/Aliyun NTP — safe to keep.)
  networking.timeServers = [
    "203.107.6.88"
    "120.25.115.20"
  ];

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";

  # ── Services ──────────────────────────────────────────
  services.nps-ehang = {
    enable = true;
    webIp = "0.0.0.0"; # exposed through NAT mapping; protected by admin password
    webPort = 8080;
    bridgeIp = "0.0.0.0";
    bridgePort = 8024;
    adminPassword = secrets.npsWebPassword;
    allowPorts = ["1080-1081"];
  };

  services.workbuddy2api = {
    enable = true;
    port = 7863;
    openFirewall = false; # loopback-only; managed over an SSH tunnel
    apiKey = secrets.workbuddyApiKey;
  };

  services.cpa = {
    enable = true;
    host = "0.0.0.0"; # exposed through NAT mapping; api-keys gate access
    port = 8317;
    apiKeys = [secrets.cpaApiKey];
    managementSecretKey = secrets.cpaManagementKey;
  };

  # Local upstream: workbuddy2api. /var/lib/cpa/config.yaml is written once on
  # first boot and then owned by the management panel / manual edits; see
  # Share/config/vps/README.md for the deployed upstream configuration.

  system.stateVersion = "25.11";
}
