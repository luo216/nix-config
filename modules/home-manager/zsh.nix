{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.customZsh;
in
{
  options.programs.customZsh = {
    enable = mkEnableOption "zsh shell";

    package = mkOption {
      type = types.package;
      default = pkgs.zsh;
      defaultText = "pkgs.zsh";
      description = "The zsh package to use.";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      inherit (cfg) package;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "bira";
        plugins = [ "vi-mode" ];
      };
      history = {
        size = 10000;
        save = 10000;
        share = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        extended = true;
      };
      initContent =
        let
          zshEarly = lib.mkOrder 500 ''
            export EDITOR="nvim"
            export VISUAL="nvim"
            export RAINBARF="$HOME/.config/rainbarf/rainbarf.conf"
            export NPM_CONFIG_PREFIX="$HOME/.npm-global"
            export PATH="$HOME/.npm-global/bin:$PATH"
            export FONTCONFIG_FILE="${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
            KEYTIMEOUT=25
          '';
          zshLate = lib.mkOrder 1000 ''
            # History navigation with up/down arrows
            bindkey '^[[A' history-beginning-search-backward
            bindkey '^[[B' history-beginning-search-forward

            # Yazi: change shell cwd on exit
            ya() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
              command yazi "$@" --cwd-file="$tmp"
              IFS= read -r -d $'\0' cwd < "$tmp"
              [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
              rm -f -- "$tmp"
            }

            # Ctrl-n accepts autosuggestion
            bindkey '^n' autosuggest-accept

            # Vi mode with kj escape and cursor shape
            bindkey -v
            bindkey -M viins 'kj' vi-cmd-mode
            function zle-keymap-select {
              if [[ $KEYMAP == vicmd ]]; then
                echo -ne '\e[2 q'  # block cursor
              else
                echo -ne '\e[6 q'  # bar cursor
              fi
            }
            function zle-line-init {
              echo -ne '\e[6 q'    # bar cursor on prompt
            }
            zle -N zle-keymap-select
            zle -N zle-line-init
          '';
        in
        lib.mkMerge [
          zshEarly
          zshLate
        ];
    };
  };
}
