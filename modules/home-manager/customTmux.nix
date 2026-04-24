{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customTmux;
in
{
  options.programs.customTmux = {
    enable = mkEnableOption "tmux terminal multiplexer";

    package = mkOption {
      type = types.package;
      default = pkgs.tmux;
      defaultText = "pkgs.tmux";
      description = "The tmux package to use.";
    };

    shell = mkOption {
      type = types.path;
      default = "${pkgs.zsh}/bin/zsh";
      defaultText = "pkgs.zsh/bin/zsh";
      description = "The shell to use in tmux.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      # Copy tmux configuration from templates and replace shell
      file.".config/tmux/tmux.conf".text =
        let
          tmuxConf = builtins.readFile ../templates/tmux/tmux.conf;
        in
        builtins.replaceStrings
          [ "set -g default-command /bin/zsh" ]
          [ "set -g default-command ${cfg.shell}" ]
          tmuxConf;

      # Copy plugins from templates
      file.".config/tmux/plugins" = {
        source = ../templates/tmux/plugins;
        recursive = true;
      };
    };
  };
}
