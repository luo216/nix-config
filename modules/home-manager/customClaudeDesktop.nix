{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.customClaudeDesktop;
  linuxConfigFile = "${config.xdg.configHome}/Claude/claude_desktop_linux_config.json";
in
{
  options.programs.customClaudeDesktop = with lib; {
    enable = mkEnableOption "Claude Desktop with NixOS cowork sandbox configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.claude-desktop;
      defaultText = "pkgs.claude-desktop";
      description = "Claude Desktop package to install.";
    };

    coworkAdditionalROBinds = mkOption {
      type = types.listOf types.str;
      default = [ "/nix" ];
      description = "Read-only host paths exposed to Claude Desktop's internal cowork bubblewrap sandbox.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.claudeDesktopLinuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      config_dir="${config.xdg.configHome}/Claude"
      config_file="${linuxConfigFile}"
      mkdir -p "$config_dir"

      if [ -e "$config_file" ] && ! ${pkgs.jq}/bin/jq -e . "$config_file" >/dev/null 2>&1; then
        echo "Claude Desktop Linux config is not valid JSON: $config_file" >&2
        exit 1
      fi

      tmp_file="$(${pkgs.coreutils}/bin/mktemp)"
      if [ -e "$config_file" ]; then
        ${pkgs.jq}/bin/jq \
          --argjson required '${builtins.toJSON cfg.coworkAdditionalROBinds}' \
          '
            .preferences = (.preferences // {}) |
            .preferences.coworkBwrapMounts = (.preferences.coworkBwrapMounts // {}) |
            .preferences.coworkBwrapMounts.additionalROBinds =
              (((.preferences.coworkBwrapMounts.additionalROBinds // []) + $required) | unique)
          ' \
          "$config_file" > "$tmp_file"
      else
        ${pkgs.jq}/bin/jq -n \
          --argjson required '${builtins.toJSON cfg.coworkAdditionalROBinds}' \
          '{
            preferences: {
              coworkBwrapMounts: {
                additionalROBinds: $required
              }
            }
          }' > "$tmp_file"
      fi

      ${pkgs.coreutils}/bin/install -m 0644 "$tmp_file" "$config_file"
      ${pkgs.coreutils}/bin/rm -f "$tmp_file"
    '';
  };
}
