{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cf-ipv6-ddns;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.services.cf-ipv6-ddns = {
    enable = mkEnableOption "Cloudflare IPv6 DDNS updater";

    apiToken = mkOption {
      type = types.str;
      description = "Cloudflare API token.";
    };

    zone = mkOption {
      type = types.str;
      description = "Cloudflare zone name (e.g. example.com).";
    };

    records = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of domain names to update with AAAA record.";
    };

    interface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Network interface to read IPv6 address from (optional).";
    };

    interval = mkOption {
      type = types.str;
      default = "5m";
      description = "Update frequency (systemd time string, e.g. 5m, 10m).";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cf-ipv6-ddns = {
      description = "Cloudflare IPv6 DDNS Updater";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      path = with pkgs; [
        curl
        jq
        iproute2
        coreutils
        gawk
      ];

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };

      script = ''
        set -euo pipefail

        TOKEN=${lib.escapeShellArg cfg.apiToken}
        ${
          if cfg.interface != null
          then ''
            IPV6="$(ip -6 -o addr show dev "${cfg.interface}" scope global -temporary | awk '{print $4}' | cut -d/ -f1 | head -n1)"
          ''
          else ''
            IPV6="$(ip -6 -o addr show scope global -temporary | awk '{print $4}' | cut -d/ -f1 | head -n1)"
          ''
        }

        if [ -z "$IPV6" ]; then
          # Fallback to any global IPv6 if non-temporary address is not present
          ${
            if cfg.interface != null
            then ''
              IPV6="$(ip -6 -o addr show dev "${cfg.interface}" scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)"
            ''
            else ''
              IPV6="$(ip -6 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)"
            ''
          }
        fi

        if [ -z "$IPV6" ]; then
          echo "Warning: No global IPv6 address detected on host, skipping DDNS update." >&2
          exit 0
        fi

        echo "Detected global IPv6: $IPV6"

        ZONE_RES="$(curl -sf -X GET "https://api.cloudflare.com/client/v4/zones?name=${cfg.zone}" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json")"
        ZONE_ID="$(echo "$ZONE_RES" | jq -r '.result[0].id // empty')"

        if [ -z "$ZONE_ID" ]; then
          echo "Error: Failed to find zone ID for ${cfg.zone}" >&2
          exit 1
        fi

        ${lib.concatMapStringsSep "\n" (record: ''
          echo "Checking AAAA record for ${record}..."
          REC_RES="$(curl -sf -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=AAAA&name=${record}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json")"
          REC_ID="$(echo "$REC_RES" | jq -r '.result[0].id // empty')"
          REC_IP="$(echo "$REC_RES" | jq -r '.result[0].content // empty')"

          if [ "$REC_IP" = "$IPV6" ]; then
            echo "Record for ${record} is already up to date ($IPV6)."
          else
            if [ -n "$REC_ID" ]; then
              echo "Updating ${record} from $REC_IP to $IPV6..."
              curl -sf -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$REC_ID" \
                -H "Authorization: Bearer $TOKEN" \
                -H "Content-Type: application/json" \
                -d "{\"type\":\"AAAA\",\"name\":\"${record}\",\"content\":\"$IPV6\",\"ttl\":60,\"proxied\":false}" >/dev/null
            else
              echo "Creating AAAA record ${record} -> $IPV6..."
              curl -sf -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
                -H "Authorization: Bearer $TOKEN" \
                -H "Content-Type: application/json" \
                -d "{\"type\":\"AAAA\",\"name\":\"${record}\",\"content\":\"$IPV6\",\"ttl\":60,\"proxied\":false}" >/dev/null
            fi
            echo "Successfully updated ${record} to $IPV6"
          fi
        '') cfg.records}
      '';
    };

    systemd.timers.cf-ipv6-ddns = {
      description = "Cloudflare IPv6 DDNS Timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = cfg.interval;
      };
    };
  };
}
