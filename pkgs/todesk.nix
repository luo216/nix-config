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
  libgbm,
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
  libxcb,
  xorg,
  gtk3,
  gdk-pixbuf,
  pango,
  libz,
  libpng,
  libayatana-appindicator,
}:

let
  version = "4.8.6.2";
  todesk-unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "todesk-unwrapped";
    version = version;
    src = fetchurl {
      url = "https://dl.todesk.com/linux/todesk-v${version}-amd64.deb";
      hash = "sha256-s/Kvf8EglIkD3zqkVZVctYI/tcH17H3KF6yKTLpTyAg=";
      # dl.todesk.com is behind Tencent EdgeOne WAF; a browser UA is required
      curlOptsList = [ "--user-agent" "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0" ];
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
      mkdir -p "$out/share/icons"
      runHook postInstall
    '';

  });

in
buildFHSEnv {
  inherit version;
  pname = "todesk";
  targetPkgs = pkgs: [
    todesk-unwrapped
    pulseaudio
    nspr
    kmod
    libXi
    systemdMinimal
    glib
    libz
    libpng
    bash
    coreutils
    libX11
    libXext
    libXrandr
    glibc
    libdrm
    libgbm
    libGL
    procps
    cairo
    libXcomposite
    libXdamage
    libXfixes
    libXtst
    nss
    libXxf86vm
    libxcb
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilcursor
    gtk3
    gdk-pixbuf
    pango
    libva
  ];
  extraBwrapArgs = [
    "--tmpfs /opt/todesk"
    "--bind /var/lib/todesk /opt/todesk/config"
    "--bind ${todesk-unwrapped}/bin /opt/todesk/bin"
    "--bind /var/lib/todesk /etc/todesk"
  ];
  runScript = writeShellScript "ToDesk.sh" ''
    export LIBVA_DRIVER_NAME=iHD
    export LIBVA_DRIVERS_PATH=${todesk-unwrapped}/bin
    export LD_LIBRARY_PATH=/opt/todesk/bin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    if [ "''${1}" = 'service' ]
    then
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
