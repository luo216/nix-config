{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  asar,
  bash,
  coreutils,
  curl,
  dpkg,
  gawk,
  glib,
  gnugrep,
  gnupg,
  gnused,
  gsettings-desktop-schemas,
  gtk3,
  makeWrapper,
  nodejs,
  patchelf,
  pipewire,
  procps,
  python3,
  systemd,
  util-linux,
  xdg-utils,
  findutils,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  graphite2,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libusb1,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  wayland,
  xz,
  zstd,
  xorg,
  zlib,
  libxcrypt-legacy,
}: let
  pname = "codex-desktop";
  upstreamVersion = "26.825.51511";
  version = upstreamVersion;

  src = fetchFromGitHub {
    owner = "ilysenko";
    repo = "codex-desktop-linux";
    rev = "e021215ca0743dd1403bb4c76765e4316d9eea4a";
    hash = "sha256-mPKeLdRwZHWBLQ6uGULDaRgehdW0OSokNi64yXhbIrY=";
  };

  # OpenAI's official Linux package (amd64), pinned by the upstream repo:
  # https://github.com/ilysenko/codex-desktop-linux/blob/main/nix/upstream-linux-packages.json
  upstreamDeb = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${upstreamVersion}_amd64.deb";
    hash = "sha256-NVSwAixs+1EzJvQ/0R9xiDWncIasTXyi/z67ui1Mf0U=";
  };

  runtimeLibraries = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    systemd
    stdenv.cc.cc.lib
    wayland
    xz
    zstd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    libxcrypt-legacy
    zlib
  ];
  runtimeLibraryPath = lib.makeLibraryPath runtimeLibraries;
  launcherPath = lib.makeBinPath [
    bash
    coreutils
    curl
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    nodejs
    procps
    python3
    systemd
    util-linux
    xdg-utils
  ];
  gsettingsSchemaDataDirs = lib.concatStringsSep ":" (map (pkg:
    lib.removeSuffix "/glib-2.0/schemas" (glib.getSchemaPath pkg))
  [gsettings-desktop-schemas gtk3]);
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      asar
      bash
      coreutils
      curl
      dpkg
      gawk
      gnugrep
      gnupg
      gnused
      makeWrapper
      nodejs
      patchelf
      util-linux
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"

      source_dir="$TMPDIR/source"
      cp -R "$src" "$source_dir"
      chmod -R u+w "$source_dir"

      # Install.sh applies ASAR feature patches via npx; point it at the
      # packaged asar binary instead.
      substituteInPlace "$source_dir/scripts/lib/asar-patch.sh" \
        --replace-fail "npx --yes @electron/asar" "${asar}/bin/asar"

      export CODEX_INSTALL_TRANSACTION_ACTIVE=1
      export CODEX_INSTALL_DIR="$out/opt/codex-desktop"
      bash "$source_dir/install.sh" "${upstreamDeb}"

      app="$out/opt/codex-desktop"
      test -d "$app"

      # Repoint ELF interpreters / RUNPATHs at the Nix store (same audit as upstream).
      dynamic_linker="$(cat ${stdenv.cc}/nix-support/dynamic-linker)"
      node "$source_dir/nix/elf-runtime.cjs" fix \
        --root "$app" \
        --arch amd64 \
        --dynamic-linker "$dynamic_linker" \
        --runtime-library-path "${runtimeLibraryPath}" \
        --patchelf "${patchelf}/bin/patchelf" \
        --chatgpt-relocator "$source_dir/nix/relocate-elf-interpreter.cjs"
      patchShebangs --build "$app"

      install -Dm0644 "$app/.codex-linux/codex-desktop.png" \
        "$out/share/icons/hicolor/256x256/apps/codex-desktop.png"

      mkdir -p "$out/share/applications"
      awk '
        /^\[Desktop Action CheckForUpdates\]$/ { skip = 1; next }
        /^\[Desktop Action InstallReadyUpdate\]$/ { skip = 1; next }
        /^\[/ { skip = 0 }
        skip { next }
        /^Actions=/ { print "Actions=new-window;"; next }
        { print }
      ' "$source_dir/packaging/linux/codex-desktop.desktop" \
        > "$out/share/applications/codex-desktop.desktop"
      substituteInPlace "$out/share/applications/codex-desktop.desktop" \
        --replace-fail "/usr/bin/codex-desktop" "$out/bin/codex-desktop" \
        --replace-fail "/usr/share/applications/codex-desktop.desktop" "$out/share/applications/codex-desktop.desktop"

      makeWrapper "$app/start.sh" "$out/bin/codex-desktop" \
        --prefix PATH : "${launcherPath}" \
        --prefix PATH : "/run/current-system/sw/bin" \
        --set-default ALSA_PLUGIN_DIR "${pipewire}/lib/alsa-lib" \
        --run 'export XDG_DATA_DIRS="''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"' \
        --prefix XDG_DATA_DIRS : "${gsettingsSchemaDataDirs}" \
        --set-default BAMF_DESKTOP_FILE_HINT "$out/share/applications/codex-desktop.desktop" \
        --set-default CODEX_CLI_PATH "$app/resources/codex" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}"

      node "$source_dir/nix/elf-runtime.cjs" audit \
        --root "$app" \
        --arch amd64 \
        --dynamic-linker "$dynamic_linker" \
        --runtime-library-path "${runtimeLibraryPath}" \
        --patchelf "${patchelf}/bin/patchelf"
      node "$source_dir/nix/relocate-elf-interpreter.cjs" check \
        "$app/ChatGPT" "$dynamic_linker"

      runHook postInstall
    '';

    meta = {
      description = "Codex Desktop for Linux";
      homepage = "https://github.com/ilysenko/codex-desktop-linux";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux;
      mainProgram = "codex-desktop";
    };
  }
