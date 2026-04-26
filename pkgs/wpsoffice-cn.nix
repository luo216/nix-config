{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  runCommandLocal,
  curl,
  coreutils,
  cacert,
  alsa-lib,
  libjpeg,
  libtool,
  libxkbcommon,
  nss,
  nspr,
  udev,
  gtk3,
  libgbm,
  libusb1,
  unixODBC,
  libmysqlclient,
  libsForQt5,
  xorg,
  cups,
  dbus,
  pango,
}:

let
  pname = "wpsoffice-cn";
  version = "12.1.2.25882";

  wpsUrl = "https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25882/wps-office_12.1.2.25882.AK.preread.sw.Personal_662820_amd64.deb";
  wpsHash = "sha256-ZdYtB83mGbnbjh7wHRAt37QfZ1F/5eoFUcZYTNhGGUc=";

  src = runCommandLocal "wpsoffice-cn-${version}.deb"
    {
      outputHashAlgo = "sha256";
      outputHash = wpsHash;

      nativeBuildInputs = [ curl coreutils ];

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

  nativeBuildInputs = [ autoPatchelfHook ];

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
    unixODBC
    libsForQt5.qtbase
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
  ];

  dontWrapQtApps = true;

  stripAllList = [ "opt" ];

  runtimeDependencies = map lib.getLib [ cups dbus pango ];

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

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
    patchelf --replace-needed libmysqlclient.so.18 libmysqlclient.so $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    patchelf --add-rpath ${libmysqlclient}/lib/mariadb $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    for i in $out/bin/*; do
      substituteInPlace $i \
        --replace-fail '[ $haveConf -eq 1 ] &&' '[ ! $currentMode ] ||'
    done
  '';

  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.cn";
    changelog = "https://linux.wps.cn/wpslinuxlog";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = licenses.unfree;
    mainProgram = "wps";
  };
}
