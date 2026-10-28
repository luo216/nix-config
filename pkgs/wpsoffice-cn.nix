{
  lib,
  stdenv,
  autoPatchelfHook,
  runCommandLocal,
  curl,
  coreutils,
  cacert,
  alsa-lib,
  libjpeg,
  libtool,
  libxkbcommon,
  nspr,
  udev,
  gtk3,
  libgbm,
  libusb1,
  unixodbc,
  libmysqlclient,
  libsForQt5,
  libxdamage,
  libxtst,
  libxv,
  cups,
  dbus,
  pango,
}: let
  pname = "wpsoffice-cn";
  version = "12.1.2.28080";

  wpsUrl = "https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/28080/wps-office_12.1.2.28080.AK.preread.sw.Personal_765474_amd64.deb";
  wpsHash = "sha256-L6mZ9gpx4hCTq0nvbX9h12aMhEv+vzCQfSwpDkYPm+A=";

  src =
    runCommandLocal "wpsoffice-cn-${version}.deb"
    {
      outputHashAlgo = "sha256";
      outputHash = wpsHash;

      nativeBuildInputs = [curl coreutils];

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    }
    ''
      readonly SECURITY_KEY="7f8faaaa468174dc1c9cd62e5f218a5b"

      timestamp10=$(date '+%s')
      md5hash=($(printf '%s' "$SECURITY_KEY${lib.removePrefix "https://wps-linux-personal.wpscdn.cn" wpsUrl}$timestamp10" | md5sum))

      curl --retry 3 --retry-delay 3 "${wpsUrl}?t=$timestamp10&k=$md5hash" > $out
    '';
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [autoPatchelfHook];

    buildInputs = [
      alsa-lib
      libjpeg
      libtool
      libxkbcommon
      nspr
      udev
      gtk3
      libgbm
      libusb1
      unixodbc
      libsForQt5.qtbase
      libxdamage
      libxtst
      libxv
    ];

    dontWrapQtApps = true;

    stripAllList = ["opt"];

    runtimeDependencies = map lib.getLib [cups dbus pango];

    unpackPhase = ''
      ar x $src
      tar -xf data.tar.xz

      rm -rf usr/share/{fonts,locale}
      rm -f usr/bin/misc
      rm -rf opt/kingsoft/wps-office/{desktops,INSTALL}
      rm -f opt/kingsoft/wps-office/office6/lib{peony-wpsprint-menu-plugin,bz2,jpeg,stdc++,gcc_s,odbc*,dbus-1}.so*
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      cp -r opt $out
      cp -r usr/{bin,share} $out

      for i in $out/bin/*; do
        substituteInPlace $i \
          --replace-fail /opt/kingsoft/wps-office $out/opt/kingsoft/wps-office
      done

      for i in $out/share/applications/*; do
        substituteInPlace $i \
          --replace-fail /usr/bin $out/bin
      done

      # 禁用 WPS 自带的默认应用检查与修复脚本
      # 这些脚本硬编码了 /usr/bin/gio 和 gvfs-mime，在 NixOS 上必定失败并输出 needasso，
      # 导致每次打开 WPS 都会误弹“不是系统默认办公软件”提示。
      # 系统层面的 MIME 关联已由 Home Manager (xdg.mimeApps) 声明式管理。
      for s in $(find $out -name "assocheck.sh" -o -name "desktopcheck.sh" -o -name "repairasso.sh" -o -name "repair.sh"); do
        echo '#!/bin/sh' > "$s"
        echo 'exit 0' >> "$s"
        chmod +x "$s"
      done

      runHook postInstall
    '';

    preFixup = ''
      patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
      patchelf --replace-needed libmysqlclient.so.18 libmysqlclient.so $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
      patchelf --add-rpath ${libmysqlclient}/lib/mariadb $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    '';

    meta = with lib; {
      description = "Office suite, formerly Kingsoft Office";
      homepage = "https://www.wps.cn";
      changelog = "https://linux.wps.cn/wpslinuxlog";
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      hydraPlatforms = [];
      license = licenses.unfree;
      mainProgram = "wps";
    };
  }
