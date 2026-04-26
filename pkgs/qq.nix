{
  alsa-lib,
  libuuid,
  cups,
  dpkg,
  fetchurl,
  glib,
  libssh2,
  gtk3,
  lib,
  libayatana-appindicator,
  libdrm,
  libgcrypt,
  libkrb5,
  libnotify,
  libgbm,
  libpulseaudio,
  libGL,
  nss,
  xorg,
  systemd,
  stdenv,
  vips,
  at-spi2-core,
  autoPatchelfHook,
  writeShellScript,
  makeShellWrapper,
  wrapGAppsHook3,
  commandLineArgs ? "",
  disableAutoUpdate ? true,
}:

let
  version = "3.2.25-2026-02-05";
  src = fetchurl {
    url = "https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.25_260205_amd64_01.deb";
    hash = "sha256-TVEHWd8lyfhcfj6E83XDaFq2L75wtNNI97osG6iCvuA=";
  };
in
stdenv.mkDerivation {
  pname = "qq";
  inherit version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeShellWrapper
    wrapGAppsHook3
    dpkg
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    glib
    gtk3
    libdrm
    libpulseaudio
    libgcrypt
    libkrb5
    libgbm
    nss
    vips
    xorg.libXdamage
  ];

  dontWrapGApps = true;

  runtimeDependencies = map lib.getLib [
    systemd
    libkrb5
  ];

  installPhase =
    let
      versionConfigScript = writeShellScript "qq-version-config.sh" ''
        set -e

        if [[ -z "$INTERNAL_VERSION" ]]; then
          echo "INTERNAL_VERSION is not set, skipping version config management"
          exit 0
        fi

        CONFIG_PATH="$HOME/.config/QQ/versions/config.json"
        CONFIG_DIR="$(dirname "$CONFIG_PATH")"

        if [[ ! -f "$CONFIG_PATH" ]]; then
          if [[ ! -d "$CONFIG_DIR" ]]; then
            echo "Creating QQ version config directory at $CONFIG_DIR"
            mkdir -p "$CONFIG_DIR"
          fi
        else
          baseVersion=$(sed -n 's/.*"baseVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_PATH")
          currentVersion=$(sed -n 's/.*"curVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_PATH")

          if [[ "$baseVersion" == "$INTERNAL_VERSION" && "$currentVersion" == "$INTERNAL_VERSION" ]]; then
            echo "Version config file already up to date"

            if [[ -w "$CONFIG_PATH" ]]; then
              echo "Making existing version config file read-only"
              chmod u-w "$CONFIG_PATH"
            fi

            exit 0
          fi

          if [[ ! -w "$CONFIG_PATH" ]]; then
            echo "Making existing version config file writable temporarily"
            chmod u+w "$CONFIG_PATH"
          fi
        fi

        cat > "$CONFIG_PATH" << EOF
        {
          "_comment": "This file is managed by the qq-version-config.sh to disable auto updates, do not edit it manually. Set the `disableAutoUpdate` option to false to disable this behavior.",
          "baseVersion": "$INTERNAL_VERSION",
          "curVersion": "$INTERNAL_VERSION",
          "buildId": "''${INTERNAL_VERSION##*-}"
        }
        EOF

        chmod u-w "$CONFIG_PATH"
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/bin
      cp -r opt $out/opt
      cp -r usr/share $out/share
      substituteInPlace $out/share/applications/qq.desktop \
        --replace-fail "/opt/QQ/qq" "$out/bin/qq" \
        --replace-fail "/usr/share" "$out/share"
      makeShellWrapper $out/opt/QQ/qq $out/bin/qq \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix LD_PRELOAD : "${lib.makeLibraryPath [ libssh2 ]}/libssh2.so.1" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libGL
            libuuid
          ]
        }" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
        --add-flags ${lib.escapeShellArg commandLineArgs} \
        "''${gappsWrapperArgs[@]}" ${lib.optionalString disableAutoUpdate ''
          \
          --set INTERNAL_VERSION "$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' $out/opt/QQ/resources/app/package.json)" \
          --run '${versionConfigScript} || true'
        ''}

      # Remove bundled libraries
      rm -r $out/opt/QQ/resources/app/sharp-lib
      rm -r $out/opt/QQ/resources/app/libssh2.so.1

      ln -s ${libayatana-appindicator}/lib/libayatana-appindicator3.so \
        $out/opt/QQ/libappindicator3.so

      ln -s ${libnotify}/lib/libnotify.so \
        $out/opt/QQ/libnotify.so

      runHook postInstall
    '';

  meta = with lib; {
    homepage = "https://im.qq.com/index/";
    description = "Messaging app";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "qq";
  };
}
