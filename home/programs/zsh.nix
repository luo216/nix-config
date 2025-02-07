{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zsh
    oh-my-zsh
  ];

  programs.zsh = {
    enable = true;

    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      lsblk = "lsblk -a --output 'NAME,LABEL,FSTYPE,SIZE,FSUSE%,RO,TYPE,MOUNTPOINTS'";
      proxySet = "export http_proxy=http://127.0.0.1:2334&&export https_proxy=http://127.0.0.1:2334";
      proxyUnSet = "unset http_proxy&&unset https_proxy";
    };

    initExtra = ''
      # 配置oh-my-zsh
      export ZSH=$HOME/.nix-profile/share/oh-my-zsh
      ZSH_THEME="bira"

      plugins=(
        git
        vi-mode
      )
      source $ZSH/oh-my-zsh.sh

      # 设置 FZF_DEFAULT_OPTS 环境变量
      export FZF_DEFAULT_OPTS='--preview-window=right:35% --preview "(highlight -O ansi {} || cat {}) 2> /dev/null | head -500"'

      # rainbarf
      export RAINBARF=~/.config/rainbarf/rainbarf.conf rainbarf

      # 设置vi模式下不同模式下光标的样式
      VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
      VI_MODE_SET_CURSOR=true
      # 设置kj
      bindkey -M viins 'kj' vi-cmd-mode
      KEYTIMEOUT=25
      # 设置ctrl-n补全
      bindkey '^n' autosuggest-accept

      # 设置yazi退出留在当前目录
      function ya() {
      	tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      	yazi --cwd-file="$tmp"
      	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }
    '';
  };
}
