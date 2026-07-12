{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customCtfMsf;

  exploitDbRoot = "${cfg.exploitdbPackage}/share/exploitdb";

  msfdbInit = pkgs.writeShellScriptBin "msfdb-init-local" ''
    set -euo pipefail

    export PGDATA="''${PGDATA:-$HOME/.local/share/msf/pgdata}"
    export MSF_DB="''${MSF_DB:-$HOME/.msf4/database.yml}"

    mkdir -p "$PGDATA" "$(dirname "$MSF_DB")" "$HOME/.msf4"

    if [ ! -f "$PGDATA/PG_VERSION" ]; then
      ${pkgs.postgresql}/bin/initdb -D "$PGDATA"
    fi

    cat > "$MSF_DB" <<EOF
production:
  adapter: postgresql
  database: msf
  username: $USER
  password:
  host: 127.0.0.1
  port: 5432
  pool: 200
  timeout: 5
EOF

    echo "Initialized local Metasploit database at $PGDATA"
    echo "Database config written to $MSF_DB"
  '';

  msfdbStart = pkgs.writeShellScriptBin "msfdb-start-local" ''
    set -euo pipefail

    export PGDATA="''${PGDATA:-$HOME/.local/share/msf/pgdata}"

    if [ ! -f "$PGDATA/PG_VERSION" ]; then
      echo "PGDATA is not initialized. Run msfdb-init-local first." >&2
      exit 1
    fi

    ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" -l "$PGDATA/postgresql.log" start

    if ! ${pkgs.postgresql}/bin/psql -h 127.0.0.1 -p 5432 -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = 'msf'" | grep -q 1; then
      ${pkgs.postgresql}/bin/createdb -h 127.0.0.1 -p 5432 msf
    fi
  '';

  msfdbStop = pkgs.writeShellScriptBin "msfdb-stop-local" ''
    set -euo pipefail

    export PGDATA="''${PGDATA:-$HOME/.local/share/msf/pgdata}"

    if [ ! -f "$PGDATA/PG_VERSION" ]; then
      echo "PGDATA is not initialized. Nothing to stop." >&2
      exit 0
    fi

    ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" stop
  '';

  msfconsoleDb = pkgs.writeShellScriptBin "msfconsole-db" ''
    set -euo pipefail
    exec ${cfg.metasploitPackage}/bin/msfconsole "$@"
  '';

  msfrpcdLocal = pkgs.writeShellScriptBin "msfrpcd-local" ''
    set -euo pipefail
    exec ${cfg.metasploitPackage}/bin/msfrpcd "$@"
  '';

  msfmcpdLocal = pkgs.writeShellScriptBin "msfmcpd-local" ''
    set -euo pipefail
    if [ -x ${cfg.metasploitPackage}/bin/msfmcpd ]; then
      exec ${cfg.metasploitPackage}/bin/msfmcpd "$@"
    fi
    echo "msfmcpd is not present in the current metasploit package." >&2
    exit 1
  '';
in
{
  options.programs.customCtfMsf = {
    enable = mkEnableOption "Metasploit + exploit database toolkit";

    metasploitPackage = mkOption {
      type = types.package;
      default = pkgs.metasploit;
      defaultText = "pkgs.metasploit";
      description = "Metasploit Framework package.";
    };

    exploitdbPackage = mkOption {
      type = types.package;
      default = pkgs.exploitdb;
      defaultText = "pkgs.exploitdb";
      description = "ExploitDB package providing the local exploit database.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        cfg.metasploitPackage
        cfg.exploitdbPackage
        pkgs.postgresql
        msfdbInit
        msfdbStart
        msfdbStop
        msfconsoleDb
        msfrpcdLocal
        msfmcpdLocal
      ];

      sessionVariables = {
        EXPLOITDB = exploitDbRoot;
      };

      file.".msf4/modules/README.md".text = ''
        Place local Metasploit modules in this directory if needed.
      '';
    };
  };
}
