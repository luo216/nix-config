{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  asar,
  bash,
  cacert,
  cargo,
  coreutils,
  curl,
  findutils,
  gawk,
  gcc,
  glib,
  gnugrep,
  gnumake,
  gnused,
  gtk3,
  makeWrapper,
  nodejs,
  _7zz,
  patchelf,
  procps,
  python3,
  systemd,
  unzip,
  xdg-utils,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  libdrm,
  libgbm,
  libglvnd,
  libxcrypt-legacy,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  wayland,
  xorg,
  zlib,
}: let
  pname = "codex-desktop";
  version = "0-unstable-2026-06-08";

  src = fetchFromGitHub {
    owner = "ilysenko";
    repo = "codex-desktop-linux";
    rev = "27901613204cfe6c9ee9c790fa702b1e7cdb6295";
    hash = "sha256-F3S7OwBeVlj4KcY44YAYsIpSpTPP4QmuLQzyXUc5LEI=";
  };

  codexDmg = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/Codex.dmg";
    hash = "sha256-QtVs+lj5wDyQabjx6imzjZmTLSFJXF7CsQNnxznbCw8=";
  };

  electronLibs = [
    glib
    gtk3
    pango
    cairo
    gdk-pixbuf
    atk
    at-spi2-atk
    at-spi2-core
    nss
    nspr
    dbus
    cups
    expat
    libdrm
    mesa
    libgbm
    alsa-lib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    libxkbcommon
    xorg.libXcursor
    xorg.libXi
    xorg.libXtst
    xorg.libXScrnSaver
    libglvnd
    systemd
    wayland
  ];

  electronLibPath = lib.makeLibraryPath electronLibs;
  runtimeLibPath = lib.makeLibraryPath [
    libxcrypt-legacy
    stdenv.cc.cc.lib
    zlib
  ];
  launcherPath = lib.makeBinPath [
    bash
    coreutils
    curl
    findutils
    gawk
    gnugrep
    gnused
    nodejs
    procps
    python3
    systemd
    xdg-utils
  ];

  patchNixGeneratedScripts = installDir: ''
    if [ -f "${installDir}/start.sh" ]; then
      ${gnused}/bin/sed -i '1s|^#!/bin/bash$|#!${bash}/bin/bash|' "${installDir}/start.sh"
    fi
  '';

  patchNixInstalledApp = installDir: ''
        if [ -f "${installDir}/start.sh" ]; then
          ${gnused}/bin/sed -i '1s|^#!/bin/bash$|#!${bash}/bin/bash|' "${installDir}/start.sh"
          if ! grep -q "NixOS Electron library path" "${installDir}/start.sh"; then
            ${gnused}/bin/sed -i '2i# NixOS Electron library path for dlopen()ed GL/EGL libraries.\nexport LD_LIBRARY_PATH="${electronLibPath}:${runtimeLibPath}:''${LD_LIBRARY_PATH:-}"' "${installDir}/start.sh"
          fi
          if ! grep -q "codex_nixos_add_runtime_library_dirs" "${installDir}/start.sh"; then
            ${gnused}/bin/sed -i '/^set -euo pipefail$/a\
    \
    codex_nixos_add_runtime_library_dirs() {\
        local cache_home="''${XDG_CACHE_HOME:-''${HOME:-}/.cache}"\
        local runtime_root="''${CODEX_PRIMARY_RUNTIME_ROOT:-''${CODEX_RUNTIME_ROOT:-$cache_home/codex-runtimes/codex-primary-runtime}}"\
        local dir\
    \
        for dir in \\\
            "$runtime_root/dependencies/python/lib" \\\
            "$runtime_root/dependencies/python/lib/python3.12/site-packages/pillow.libs" \\\
            "$runtime_root/dependencies/python/lib/python3.12/site-packages/numpy.libs" \\\
            "$runtime_root/dependencies/node/node_modules/@img/sharp-libvips-linux-x64/lib" \\\
            "$runtime_root/dependencies/node/node_modules/@img/sharp-linux-x64/lib" \\\
            "$runtime_root/dependencies/node/node_modules/@napi-rs/canvas-linux-x64-gnu"; do\
            if [ -d "$dir" ]; then\
                LD_LIBRARY_PATH="$dir:''${LD_LIBRARY_PATH:-}"\
            fi\
        done\
    \
        export LD_LIBRARY_PATH\
    }\
    \
    codex_nixos_add_runtime_library_dirs' "${installDir}/start.sh"
          fi

          if ! grep -q "\$HOME/.npm-global/bin/codex" "${installDir}/start.sh"; then
            ${gnused}/bin/sed -i '/"\$HOME\/.local\/bin\/codex" \\/a\
        "$HOME/.npm-global/bin/codex" \\' "${installDir}/start.sh"
          fi
        fi

        if [ -f "${installDir}/electron" ]; then
          patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
            --set-rpath "${installDir}:${electronLibPath}" \
            "${installDir}/electron"

          if [ -f "${installDir}/chrome_crashpad_handler" ]; then
            patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
              "${installDir}/chrome_crashpad_handler" || true
          fi

          if [ -f "${installDir}/chrome-sandbox" ]; then
            patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
              "${installDir}/chrome-sandbox" || true
          fi

          find "${installDir}" -maxdepth 1 -name "*.so*" -type f | while read -r so; do
            patchelf --set-rpath "${electronLibPath}" "$so" 2>/dev/null || true
          done
        fi
  '';

  payload = stdenv.mkDerivation {
    pname = "codex-desktop-payload";
    inherit version src;
    __structuredAttrs = true;

    nativeBuildInputs = [
      bash
      cargo
      curl
      gcc
      gnumake
      gnused
      makeWrapper
      nodejs
      _7zz
      patchelf
      python3
      unzip
    ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-eEgK3eI+SWqp5oHXWRp70iELjW8qXqT733h47ZmZlv8=";
    unsafeDiscardReferences.out = true;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
            runHook preInstall

            export HOME="$TMPDIR/home"
            export npm_config_cache="$TMPDIR/npm-cache"
            export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
      export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
      export npm_config_cafile="$SSL_CERT_FILE"
      export CARGO_HOME="$TMPDIR/cargo-home"
      export CODEX_MANAGED_NODE_SOURCE="${nodejs}"
      mkdir -p "$HOME" "$npm_config_cache" "$CARGO_HOME"

            source_dir="$TMPDIR/codex-source"
            mkdir -p "$source_dir"
            cp -R ./. "$source_dir/"
            chmod -R u+w "$source_dir"
            cp ${codexDmg} "$source_dir/Codex.dmg"

            npm_tools="$TMPDIR/npm-tools"
            npm install --prefix "$npm_tools" --ignore-scripts asar @electron/rebuild
            patchShebangs "$npm_tools"
            export PATH="$npm_tools/node_modules/.bin:$PATH"
            substituteInPlace "$source_dir/scripts/lib/asar-patch.sh" \
              --replace-fail "npx --yes asar" "asar" \
              --replace-fail "npx asar" "asar"
      substituteInPlace "$source_dir/scripts/lib/dmg.sh" \
        --replace-fail "npx --yes asar" "asar"
      substituteInPlace "$source_dir/scripts/patches/computer-use.js" \
        --replace-fail 'throw new Error("Required Linux Computer Use plugin gate patch failed: could not enable bundled Computer Use on Linux");' \
        'console.warn("WARN: Could not enable bundled Computer Use on Linux - skipping Computer Use plugin gate patch"); return currentSource;'

      export CODEX_INSTALL_DIR="$out/opt/codex-desktop"
            ${bash}/bin/bash "$source_dir/install.sh" "$source_dir/Codex.dmg"

            rm -rf "$CODEX_INSTALL_DIR/resources/plugins/openai-bundled/plugins/computer-use"
            marketplace="$CODEX_INSTALL_DIR/resources/plugins/openai-bundled/.agents/plugins/marketplace.json"
            if [ -f "$marketplace" ]; then
              node - "$marketplace" <<'NODE'
            const fs = require("fs");
            const marketplacePath = process.argv[2];
            const marketplace = JSON.parse(fs.readFileSync(marketplacePath, "utf8"));
            marketplace.plugins = (marketplace.plugins || []).filter((plugin) => plugin.name !== "computer-use");
            fs.writeFileSync(marketplacePath, JSON.stringify(marketplace, null, 2) + "\n");
      NODE
            fi

            asar extract "$CODEX_INSTALL_DIR/resources/app.asar" "$CODEX_INSTALL_DIR/resources/app-extracted"
            rm -f "$CODEX_INSTALL_DIR/resources/app.asar"
            rm -rf "$CODEX_INSTALL_DIR/resources/app.asar.unpacked"

            ${patchNixGeneratedScripts "$out/opt/codex-desktop"}

            runHook postInstall
    '';
  };
in
  stdenv.mkDerivation {
    inherit pname version;
    src = payload;

    nativeBuildInputs = [
      asar
      makeWrapper
      patchelf
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt"
      cp -aT "$src/opt/codex-desktop" "$out/opt/codex-desktop"
      chmod -R u+w "$out/opt/codex-desktop"

      resources_dir="$out/opt/codex-desktop/resources"
      install -Dm0755 /dev/stdin "$resources_dir/bin/codex" <<'SH'
      #!${bash}/bin/bash
      set -euo pipefail

      if [ -n "''${CODEX_CLI_PATH:-}" ] && [ "''${CODEX_CLI_PATH:-}" != "$0" ] && [ -x "$CODEX_CLI_PATH" ]; then
        exec "$CODEX_CLI_PATH" "$@"
      fi

      for candidate in \
        "$HOME/.npm-global/bin/codex" \
        "$HOME/.local/bin/codex" \
        "$HOME/.bun/bin/codex" \
        "$HOME/.local/share/pnpm/codex" \
        "/run/current-system/sw/bin/codex" \
        "/usr/local/bin/codex" \
        "/usr/bin/codex"
      do
        if [ "$candidate" != "$0" ] && [ -x "$candidate" ]; then
          exec "$candidate" "$@"
        fi
      done

      echo "Codex CLI is required but was not found. Set CODEX_CLI_PATH or install @openai/codex." >&2
      exit 127
      SH
      ln -sfn bin/codex "$resources_dir/codex"

      substituteInPlace "$resources_dir/app-extracted/.vite/build/main-"*.js \
        --replace-fail 'process.platform===`linux`&&(typeof codexLinuxIsTrayEnabled!==`function`||codexLinuxIsTrayEnabled())' \
        'process.platform===`linux`&&process.env.CODEX_LINUX_SYSTEM_TRAY_ENABLED!==`0`'

      (cd "$resources_dir/app-extracted" && find . -type f | LC_ALL=C sort | sed 's#^\./##') > "$TMPDIR/app.asar.ordering"
      asar pack "$resources_dir/app-extracted" "$resources_dir/app.asar" \
        --ordering "$TMPDIR/app.asar.ordering" \
        --unpack "{*.node,*.so,*.dylib}"
      rm -rf "$resources_dir/app-extracted"

      ${patchNixInstalledApp "$out/opt/codex-desktop"}

      install -Dm0644 "$out/opt/codex-desktop/.codex-linux/codex-desktop.png" \
        "$out/share/icons/hicolor/256x256/apps/codex-desktop.png"

      install -Dm0644 ${src}/packaging/linux/codex-desktop.desktop \
        "$out/share/applications/codex-desktop.desktop"
      substituteInPlace "$out/share/applications/codex-desktop.desktop" \
        --replace-fail "/usr/bin/codex-desktop" "$out/bin/codex-desktop" \
        --replace-fail "/usr/share/applications/codex-desktop.desktop" "$out/share/applications/codex-desktop.desktop"

      makeWrapper "$out/opt/codex-desktop/start.sh" "$out/bin/codex-desktop" \
        --run 'if [ -n "''${HOME:-}" ]; then export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"; fi' \
        --run 'user_name="''${USER:-$(id -un 2>/dev/null || true)}"; if [ -n "$user_name" ]; then export PATH="/etc/profiles/per-user/$user_name/bin:$PATH"; fi' \
        --prefix PATH : "${launcherPath}" \
        --prefix LD_LIBRARY_PATH : "${electronLibPath}" \
        --prefix LD_LIBRARY_PATH : "${runtimeLibPath}" \
        --prefix PATH : "/run/current-system/sw/bin"

      runHook postInstall
    '';

    meta = {
      description = "Codex Desktop for Linux";
      homepage = "https://github.com/ilysenko/codex-desktop-linux";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "codex-desktop";
    };
  }
