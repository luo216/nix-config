{
  stdenv,
  lib,
  procps,
  fetchurl,
  dpkg,
  writeShellScript,
  buildFHSEnv,
  nspr,
  kmod,
  systemdMinimal,
  glib,
  pulseaudio,
  libXext,
  libX11,
  libXrandr,
  glibc,
  cairo,
  libva,
  libdrm,
  coreutils,
  libXi,
  libGL,
  bash,
  libXcomposite,
  libXdamage,
  libXfixes,
  libXtst,
  nss,
  libXxf86vm,
  gtk3,
  gdk-pixbuf,
  pango,
  libz,
  libayatana-appindicator,
  xorg,
  libglvnd,
  mesa,
  libgbm,
  libxkbcommon,
  libpng,
}:

let
  version = "4.8.6.2";
  runtimeLibs = [
    pulseaudio
    nspr
    kmod
    libXi
    systemdMinimal
    glib
    libz
    bash
    coreutils
    libX11
    libXext
    libXrandr
    glibc
    libdrm
    libGL
    procps
    cairo
    libXcomposite
    libXdamage
    libXfixes
    libXtst
    nss
    libXxf86vm
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilkeysyms
    xorg.xcbutilimage
    xorg.xcbutilrenderutil
    gtk3
    gdk-pixbuf
    pango
    libva
    libglvnd
    mesa
    libgbm
    libxkbcommon
    libpng
    stdenv.cc.cc.lib
  ];
  todesk-unwrapped = stdenv.mkDerivation {
    pname = "todesk-unwrapped";
    inherit version;
    src = fetchurl {
      url = "https://dl.todesk.com/linux/todesk-v${version}-amd64.deb";
      hash = "sha256-s/Kvf8EglIkD3zqkVZVctYI/tcH17H3KF6yKTLpTyAg=";
      curlOptsList = [
        "-A"
        "Mozilla/5.0"
        "-e"
        "https://www.todesk.com/linux.html"
      ];
    };
    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack
      dpkg -x $src ./todesk-src
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib"
      cp -r todesk-src/* "$out"
      cp "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1" "$out/opt/todesk/bin/libappindicator3.so.1"
      mv "$out/opt/todesk/bin" "$out/bin"
      cp "$out/bin/libmfx.so.1" "$out/lib"
      cp "$out/bin/libglut.so.3" "$out/lib"
      mkdir "$out/opt/todesk/config"
      mkdir "$out/opt/todesk/bin"
      mkdir -p "$out/share/applications"
      mkdir "$out/share/icons"
      runHook postInstall
    '';
  };
in
buildFHSEnv {
  pname = "todesk";
  inherit version;
  targetPkgs = _pkgs: [
    todesk-unwrapped
  ] ++ runtimeLibs;
  extraBwrapArgs = [
    "--tmpfs /opt/todesk"
    "--bind /var/lib/todesk /opt/todesk/config"
    "--bind ${todesk-unwrapped}/bin /opt/todesk/bin"
    "--bind /var/lib/todesk /etc/todesk"
  ];
  runScript = writeShellScript "ToDesk.sh" ''
    export HOME=/var/lib/todesk
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_STATE_HOME="$HOME/.local/state"
    export XDG_RUNTIME_DIR="/run/todesk"
    export LIBVA_DRIVER_NAME=iHD
    export LIBVA_DRIVERS_PATH=${todesk-unwrapped}/bin
    export LD_LIBRARY_PATH=/opt/todesk/bin:${lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"
    if [ "''${1}" = 'service' ]; then
      /opt/todesk/bin/ToDesk_Service
    else
      /opt/todesk/bin/ToDesk
    fi
  '';
  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/icons"
    cp ${todesk-unwrapped}/usr/share/applications/todesk.desktop $out/share/applications
    cp -rf ${todesk-unwrapped}/usr/share/icons/* $out/share/icons
    substituteInPlace "$out/share/applications/todesk.desktop" \
      --replace-fail '/opt/todesk/bin/ToDesk' "$out/bin/todesk desktop"
    substituteInPlace "$out/share/applications/todesk.desktop" \
      --replace-fail '/opt/todesk/bin' "${todesk-unwrapped}/lib"
  '';
  meta = {
    description = "Remote Desktop Application";
    homepage = "https://www.todesk.com/linux.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "todesk";
  };
}
