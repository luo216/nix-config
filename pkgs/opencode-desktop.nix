# OpenCode Desktop — official Electron GUI for the open-source AI coding agent.
# Packaged from the upstream Linux .deb (opencode.ai/download).
#
# 注意:下载 URL 是 "stable" 频道,上游发新版时这里的 hash 会失配,
# 届时更新 version + hash 即可(真实文件名形如 opencode_<ver>_amd64.deb)。
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeShellWrapper,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "opencode-desktop";
  version = "1.16.2";

  src = fetchurl {
    url = "https://opencode.ai/download/stable/linux-x64-deb";
    name = "opencode-desktop-${version}.deb";
    hash = "sha256-8bgyEz+xKpvkNBbrNVhpY9aAc4l3qKldHaCAKjbk1d4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    makeShellWrapper
    dpkg
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
  ];

  dontWrapGApps = true;

  # app 同时打包了 glibc 与 musl 两套预编译原生模块(@parcel/watcher、msgpackr-extract)。
  # musl 变体在 glibc 系统上不会被加载,忽略其 musl libc 依赖即可。
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  runtimeDependencies = [ (lib.getLib systemd) ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt $out/share
    cp -r opt/OpenCode $out/opt/OpenCode
    cp -r usr/share/icons $out/share/icons
    cp -r usr/share/applications $out/share/applications

    # chrome-sandbox 需要 setuid root(nix store 无法满足),删除后 Electron
    # 退回内核 unprivileged userns 沙箱(NixOS 默认开启)。
    rm -f $out/opt/OpenCode/chrome-sandbox

    makeShellWrapper "$out/opt/OpenCode/@opencode-aidesktop" "$out/bin/opencode-desktop" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      "''${gappsWrapperArgs[@]}"

    substituteInPlace "$out/share/applications/@opencode-aidesktop.desktop" \
      --replace-fail '"/opt/OpenCode/@opencode-aidesktop"' "$out/bin/opencode-desktop"

    runHook postInstall
  '';

  meta = {
    homepage = "https://opencode.ai";
    description = "OpenCode desktop app (Electron) — the open source AI coding agent";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "opencode-desktop";
  };
}
