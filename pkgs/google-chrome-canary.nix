# Google Chrome Canary for NixOS
# Based on: https://github.com/nix-community/browser-previews
{
  fetchurl,
  lib,
  stdenv,
  patchelf,
  makeWrapper,

  # Linked dynamic libraries.
  glib,
  fontconfig,
  freetype,
  pango,
  cairo,
  libX11,
  libXi,
  atk,
  nss,
  nspr,
  libXcursor,
  libXext,
  libXfixes,
  libXrender,
  libXScrnSaver,
  libXcomposite,
  libxcb,
  alsa-lib,
  libXdamage,
  libXtst,
  libXrandr,
  libxshmfence,
  expat,
  cups,
  dbus,
  gtk3,
  gtk4,
  gdk-pixbuf,
  gcc-unwrapped,
  at-spi2-atk,
  at-spi2-core,
  libkrb5,
  libdrm,
  libglvnd,
  libgbm,
  libxkbcommon,
  pipewire,
  wayland, # ozone/wayland

  # Command line programs
  coreutils,

  # command line arguments which are always set e.g. "--disable-gpu"
  # Enable VerticalTabs: --enable-features=VerticalTabs
  commandLineArgs ? "--enable-features=VerticalTabs",

  # Will crash without.
  systemd,

  # Loaded at runtime.
  libexif,
  pciutils,

  # Additional dependencies according to other distros.
  ## Ubuntu
  liberation_ttf,
  curl,
  util-linux,
  xdg-utils,
  wget,
  ## Arch Linux.
  flac,
  harfbuzz,
  icu,
  libpng,
  libopus,
  snappy,
  speechd,
  ## Gentoo
  bzip2,
  libcap,

  # Necessary for USB audio devices.
  pulseSupport ? true,
  libpulseaudio,

  gsettings-desktop-schemas,
  adwaita-icon-theme,

  # For video acceleration via VA-API (--enable-features=VaapiVideoDecoder)
  libvaSupport ? true,
  libva,

  # For Vulkan support (--enable-features=Vulkan)
  addDriverRunpath,
}:

let
  opusWithCustomModes = libopus.override { withCustomModes = true; };

  # Canary version info
  version = "149.0.7809.0";
  hash_deb_amd64 = "sha256-ma2XlY9kaTg5/QAXYhawXYmxBqdUbldRVfWkmKTenAA=";

  deps =
    [
      glib
      fontconfig
      freetype
      pango
      cairo
      libX11
      libXi
      atk
      nss
      nspr
      libXcursor
      libXext
      libXfixes
      libXrender
      libXScrnSaver
      libXcomposite
      libxcb
      alsa-lib
      libXdamage
      libXtst
      libXrandr
      libxshmfence
      expat
      cups
      dbus
      gdk-pixbuf
      gcc-unwrapped.lib
      systemd
      libexif
      pciutils
      liberation_ttf
      curl
      util-linux
      wget
      flac
      harfbuzz
      icu
      libpng
      opusWithCustomModes
      snappy
      speechd
      bzip2
      libcap
      at-spi2-atk
      at-spi2-core
      libkrb5
      libdrm
      libglvnd
      libgbm
      coreutils
      libxkbcommon
      pipewire
      wayland
    ]
    ++ lib.optional pulseSupport libpulseaudio
    ++ lib.optional libvaSupport libva
    ++ [
      gtk3
      gtk4
    ];

  pkgName = "google-chrome-canary";
in
stdenv.mkDerivation {
  inherit version;

  name = "google-chrome-canary-${version}";

  src = fetchurl {
    url = "https://dl.google.com/linux/chrome/deb/pool/main/g/${pkgName}/${pkgName}_${version}-1_amd64.deb";
    hash = hash_deb_amd64;
  };

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];
  buildInputs = [
    # needed for GSETTINGS_SCHEMAS_PATH
    gsettings-desktop-schemas
    glib
    gtk3

    # needed for XDG_ICON_DIRS
    adwaita-icon-theme
  ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
  binpath = lib.makeBinPath deps;

  installPhase = ''
    runHook preInstall

    appname=chrome-canary
    dist=canary

    exe=$out/bin/google-chrome-$dist

    mkdir -p $out/bin $out/share

    cp -a opt/* $out/share
    cp -a usr/share/* $out/share


    substituteInPlace $out/share/google/$appname/google-$appname \
      --replace-fail 'CHROME_WRAPPER' 'WRAPPER'
    substituteInPlace $out/share/applications/google-$appname.desktop \
      --replace-fail /usr/bin/google-chrome-$dist $exe
    substituteInPlace $out/share/gnome-control-center/default-apps/google-$appname.xml \
      --replace-fail /opt/google/$appname/google-$appname $exe
    if [[ -f $out/share/menu/google-$appname.menu ]]; then
      substituteInPlace $out/share/menu/google-$appname.menu \
        --replace-fail /opt $out/share \
        --replace-fail $out/share/google/$appname/google-$appname $exe
    else
        echo "share/menu file missing; paths not replaced."
    fi;

    for icon_file in $out/share/google/chrome*/product_logo_[0-9]*.png; do
      num_and_suffix="''${icon_file##*logo_}"
      if [ $dist = "stable" ]; then
        icon_size="''${num_and_suffix%.*}"
      else
        icon_size="''${num_and_suffix%_*}"
      fi
      logo_output_prefix="$out/share/icons/hicolor"
      logo_output_path="$logo_output_prefix/''${icon_size}x''${icon_size}/apps"
      mkdir -p "$logo_output_path"
      mv "$icon_file" "$logo_output_path/google-$appname.png"
    done

    makeWrapper "$out/share/google/$appname/google-$appname" "$exe" \
      --prefix LD_LIBRARY_PATH : "$rpath" \
      --prefix PATH            : "$binpath" \
      --suffix PATH            : "${lib.makeBinPath [ xdg-utils ]}" \
      --prefix XDG_DATA_DIRS   : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:${addDriverRunpath.driverLink}/share" \
      --set CHROME_WRAPPER  "google-chrome-$dist" \
      --add-flags "''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    for elf in $out/share/google/$appname/{chrome,chrome-sandbox,chrome_crashpad_handler}; do
      patchelf --set-rpath $rpath $elf
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $elf
    done

    runHook postInstall
  '';

  meta = {
    description = "Google Chrome Canary - The bleeding edge web browser for developers";
    homepage = "https://www.google.com/chrome/canary/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "google-chrome-canary";
  };
}
