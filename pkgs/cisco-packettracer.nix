{
  alsa-lib,
  appimageTools,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  coreutils,
  cups,
  dbus,
  dpkg,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libdrm,
  libgbm,
  libGL,
  libpulseaudio,
  libxkbcommon,
  makeWrapper,
  mesa,
  nspr,
  nss,
  pango,
  qt6,
  runCommand,
  runtimeShell,
  stdenv,
  systemd,
  wayland,
  wrapGAppsHook3,
  xorg,
  xdg-utils,
}:

let
  pname = "cisco-packettracer";
  version = "9.0.0";

  debSrc = fetchurl {
    url = "https://archive.org/download/packettracer900/CiscoPacketTracer_900_Ubuntu_64bit.deb";
    hash = "sha256-3ZrA1Mf8N9y2j2J/18fm+m1CAMFEklJuVhi5vRcu2SA=";
  };

  appImageSrc = runCommand "${pname}-${version}.AppImage" { nativeBuildInputs = [ dpkg ]; } ''
    mkdir -p unpacked
    dpkg-deb -x ${debSrc} unpacked
    cp unpacked/opt/pt/packettracer.AppImage $out
    chmod +x $out
  '';

  appimageContents = appimageTools.extract {
    inherit pname version;
    src = appImageSrc;
  };

  libs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libpulseaudio
    libxkbcommon
    mesa
    nspr
    nss
    pango
    qt6.qttools
    systemd
    wayland
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxkbfile
    xorg.libxshmfence
    xorg.libXtst
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;
  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = libs;

  autoPatchelfIgnoreMissingDeps = [
    "libinput.so.10"
    "libts.so.0"
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/packettracer
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/512x512/apps

    cp -r ${appimageContents}/* $out/share/packettracer/

    cat > $out/share/packettracer/packettracer-launcher <<EOF
    #!${runtimeShell}
    export PT9HOME="$out/share/packettracer"
    export QT_QPA_PLATFORM="xcb"
    export LD_LIBRARY_PATH="$out/share/packettracer/opt/pt/bin:$out/share/packettracer/usr/lib:${lib.makeLibraryPath libs}"
    cd "$out/share/packettracer/opt/pt/bin"
    exec ./PacketTracer "\$@"
    EOF
    chmod +x $out/share/packettracer/packettracer-launcher

    makeWrapper $out/share/packettracer/packettracer-launcher $out/bin/packettracer \
      --prefix PATH : "${lib.makeBinPath [ coreutils glib.bin xdg-utils ]}" \
      "''${gappsWrapperArgs[@]}"

    cp ${appimageContents}/CiscoPacketTracer-9.0.0.desktop \
      $out/share/applications/cisco-packet-tracer.desktop
    substituteInPlace $out/share/applications/cisco-packet-tracer.desktop \
      --replace-fail '@EXEC_PATH@' "$out/bin/packettracer" \
      --replace-fail 'Icon=app' 'Icon=cisco-packet-tracer'

    cp ${appimageContents}/app.png $out/share/icons/hicolor/512x512/apps/cisco-packet-tracer.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cisco Packet Tracer packaged from the upstream AppImage";
    homepage = "https://www.netacad.com/courses/packet-tracer";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "packettracer";
  };
}
