{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.network-printers;

  printerModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "CUPS printer queue name.";
      };

      description = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional human-readable description.";
      };

      location = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional printer location.";
      };

      deviceUri = lib.mkOption {
        type = lib.types.str;
        description = "Printer device URI passed to lpadmin.";
      };

      model = lib.mkOption {
        type = lib.types.str;
        default = "everywhere";
        description = "Printer model passed to lpadmin.";
      };

      ppdOptions = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "PPD options applied with lpadmin -o.";
      };

      testHosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Reachability probes for this printer. If any host responds to ping,
          the printer will be configured.
        '';
      };
    };
  };

  ensurePrinterScript =
    printer:
    let
      escapedName = lib.escapeShellArg printer.name;
      escapedUri = lib.escapeShellArg printer.deviceUri;
      escapedModel = lib.escapeShellArg printer.model;
      descriptionArg = lib.optionalString (printer.description != null) ''
        -D ${lib.escapeShellArg printer.description} \
      '';
      locationArg = lib.optionalString (printer.location != null) ''
        -L ${lib.escapeShellArg printer.location} \
      '';
      ppdArgs = lib.concatStringsSep " \\\n  " (
        map (name: "-o ${lib.escapeShellArg "${name}=${printer.ppdOptions.${name}}"}")
          (builtins.attrNames printer.ppdOptions)
      );
      ppdArgBlock = lib.optionalString (ppdArgs != "") ''
        ${ppdArgs} \
      '';
      probeBlock =
        if printer.testHosts == [ ] then
          ''
            should_configure=1
          ''
        else
          ''
            should_configure=0
            for host in ${lib.concatMapStringsSep " " lib.escapeShellArg printer.testHosts}; do
              if ${pkgs.iputils}/bin/ping -c 1 -W 1 "$host" >/dev/null 2>&1; then
                should_configure=1
                break
              fi
            done
          '';
    in
    ''
      ${probeBlock}
      if [ "$should_configure" -ne 1 ]; then
        echo "Printer ${printer.name} is not reachable, skipping."
      else
        ${pkgs.cups}/bin/lpadmin \
          -p ${escapedName} \
          ${descriptionArg}${locationArg}  -v ${escapedUri} \
          -m ${escapedModel} \
          ${ppdArgBlock}  -E
      fi
    '';

in
{
  options.services.network-printers = {
    enable = lib.mkEnableOption "event-driven network printer configuration";

    printers = lib.mkOption {
      type = lib.types.listOf printerModule;
      default = [ ];
      description = "Network printers to configure when reachable.";
    };

    dispatcherEvents = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "up"
        "dhcp4-change"
        "dhcp6-change"
        "connectivity-change"
      ]);
      default = [
        "up"
        "dhcp4-change"
      ];
      description = "NetworkManager dispatcher events that trigger printer checks.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.printers != [ ]) {
    systemd.services.ensure-network-printers = {
      description = "Ensure network printers are configured when reachable";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "cups.service"
        "network-online.target"
      ];
      after = [
        "cups.service"
        "network-online.target"
      ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = lib.concatStringsSep "\n" (map ensurePrinterScript cfg.printers);
    };

    networking.networkmanager.dispatcherScripts = [
      {
        type = "basic";
        source = pkgs.writeShellScript "ensure-network-printers-dispatcher" ''
          case "$2" in
            ${lib.concatMapStringsSep "|" lib.escapeShellArg cfg.dispatcherEvents})
              ;;
            *)
              exit 0
              ;;
          esac

          /run/current-system/sw/bin/systemctl start ensure-network-printers.service
        '';
      }
    ];
  };
}
