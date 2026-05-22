# CloakBrowser — Stealth Chromium with 58 source-level C++ patches.
# Passes Cloudflare Turnstile, reCAPTCHA v3 (0.9), FingerprintJS, etc.
# Drop-in Playwright/Puppeteer replacement.
{
  fetchurl,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  makeWrapper,
  makeFontsConf,

  # Runtime libraries
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libpulseaudio,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  wayland,
  libX11,
  libxcb,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libxshmfence,
  libXtst,

  # Font packages (required for anti-bot canvas fingerprinting)
  freefont_ttf,
  ipafont,
  liberation_ttf,
  noto-fonts,
  noto-fonts-cjk-sans,
  noto-fonts-color-emoji,
  tlwg,
  unifont,
  wqy_zenhei,

  # Desktop integration
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  xdg-utils,
}:

let
  version = "146.0.7680.177.5";
  platformTag = "linux-x64";
  archiveName = "cloakbrowser-${platformTag}.tar.gz";

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
    systemd
    wayland
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libxshmfence
    libXtst
  ];

  fonts = [
    freefont_ttf
    ipafont
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    tlwg
    unifont
    wqy_zenhei
  ];

  fontsConf = makeFontsConf {
    fontDirectories = fonts;
  };
in
stdenvNoCC.mkDerivation {
  pname = "cloakbrowser-chromium";
  inherit version;

  src = fetchurl {
    url = "https://cloakbrowser.dev/chromium-v${version}/${archiveName}";
    hash = "sha256-ShK83pX6G7G+7ytBq15cJ8Nr544749DayMZNcFIWZw4=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = libs ++ [ adwaita-icon-theme gsettings-desktop-schemas ];
  runtimeDependencies = libs;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/cloakbrowser" "$out/bin"
    tar -xzf "$src" -C "$out/lib/cloakbrowser"
    chmod +x "$out/lib/cloakbrowser/chrome"
    chmod +x "$out/lib/cloakbrowser/chromedriver"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/lib/cloakbrowser/chrome" "$out/bin/cloakbrowser-chrome" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$XDG_ICON_DIRS" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --set FONTCONFIG_FILE "${fontsConf}" \
      --set CHROME_WRAPPER "cloakbrowser-chrome"

    makeWrapper "$out/lib/cloakbrowser/chromedriver" "$out/bin/cloakbrowser-chromedriver" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}"
  '';

  meta = {
    description = "Stealth Chromium that passes every bot detection test — 58 C++ fingerprint patches";
    homepage = "https://github.com/CloakHQ/CloakBrowser";
    license = lib.licenses.unfree;
    mainProgram = "cloakbrowser-chrome";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
