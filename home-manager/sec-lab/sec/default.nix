{
  outputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    outputs.homeManagerModules.customKitty
    outputs.homeManagerModules.customZsh
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  home = {
    inherit (user) username;
    homeDirectory = "/home/${user.username}";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    font = {
      name = "Noto Sans 10";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "sec";
      email = "sec@sec-lab.local";
    };
  };

  programs.customZsh.enable = true;
  programs.customKitty.enable = true;

  # Home Manager layer: user workflow and day-to-day Web tools validated after NixOS.
  home.packages = with pkgs; [
    fastfetch
    ffuf
    gobuster
    httpx
    jq
    neovim
    nikto
    nuclei
    pipx
    sqlmap
    thc-hydra
    tmux
    whatweb
  ];

  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xsettings" version="1.0">
      <property name="Net" type="empty">
        <property name="ThemeName" type="string" value="Arc-Dark"/>
        <property name="IconThemeName" type="string" value="Papirus-Dark"/>
      </property>
      <property name="Gtk" type="empty">
        <property name="CursorThemeName" type="string" value="Bibata-Modern-Ice"/>
        <property name="CursorThemeSize" type="int" value="24"/>
        <property name="FontName" type="string" value="Noto Sans 10"/>
        <property name="MonospaceFontName" type="string" value="DejaVu Sans Mono 11"/>
      </property>
    </channel>
  '';

  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfwm4" version="1.0">
      <property name="general" type="empty">
        <property name="theme" type="string" value="Arc-Dark"/>
        <property name="title_font" type="string" value="Noto Sans Bold 10"/>
        <property name="button_layout" type="string" value="O|HMC"/>
      </property>
    </channel>
  '';

  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-desktop" version="1.0">
      <property name="backdrop" type="empty">
        <property name="screen0" type="empty">
          <property name="monitor0" type="empty">
            <property name="workspace0" type="empty">
              <property name="color-style" type="int" value="0"/>
              <property name="image-style" type="int" value="5"/>
              <property name="last-image" type="string" value="${pkgs.nixos-artwork.wallpapers.catppuccin-macchiato.gnomeFilePath}"/>
            </property>
          </property>
          <property name="monitorVirtual1" type="empty">
            <property name="workspace0" type="empty">
              <property name="color-style" type="int" value="0"/>
              <property name="image-style" type="int" value="5"/>
              <property name="last-image" type="string" value="${pkgs.nixos-artwork.wallpapers.catppuccin-macchiato.gnomeFilePath}"/>
            </property>
          </property>
        </property>
      </property>
    </channel>
  '';

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
