# Claude Desktop for Linux, unpacked from Anthropic's official .deb.
#
# The official tree ships bare co-located at usr/lib/claude-desktop/
# {claude-desktop, chrome-sandbox, resources/}, so we copy it whole —
# the ELF is a real file, never a symlink — and /proc/self/exe resolves
# inside this store path, which keeps process.resourcesPath correct by
# construction. No nixpkgs electron, no resourcesPath hack.
#
# Cowork's virtiofsd probe only matches /usr/libexec/virtiofsd and
# /usr/bin/virtiofsd, neither of which exists in the Nix store, so this
# raw package resolves the MCP/claude side but NOT the Cowork VM gates
# (qemu on PATH, /usr/share/OVMF, virtiofsd). Those need the resulting
# packages/claude-desktop-fhs.nix wrapper, which is the package one
# installs to actually use Cowork.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  addDriverRunpath,
  makeWrapper,
  # DT_NEEDED of the main Electron ELF and its co-located libs
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libcap_ng,
  libgbm,
  libseccomp,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd, # libudev.so.1
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  # dlopen'd by the Electron main process / ANGLE at runtime (not in
  # DT_NEEDED). runtimeDependencies lands these on the main ELF's runpath;
  # the co-located ANGLE libs issue their own dlopen and need libGL on
  # every ELF's runpath instead (see appendRunpaths).
  libGL,
  libayatana-appindicator,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxtst,
  pciutils,
  pipewire,
  wayland,
}: let
  # Mirrors the pinned OFFICIAL_DEB_VERSION in the community
  # claude-desktop-debian repo and the latest apt "stable" entry.
  version = "1.46388.2";

  poolBase = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop";
in
  stdenv.mkDerivation {
    pname = "claude-desktop";
    inherit version;

    src = fetchurl {
      url = "${poolBase}/claude-desktop_${version}_amd64.deb";
      hash = "sha256-mL9U6F5JFgaMQoFFmw8EMdj/aANHc/PumDEdcgZWarE=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libcap_ng
      libgbm
      libseccomp
      libxkbcommon
      nspr
      nss
      pango
      stdenv.cc.cc.lib # libstdc++ (node-pty), libgcc_s
      systemd
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
    ];

    runtimeDependencies = map lib.getLib [
      libGL
      libayatana-appindicator
      libnotify
      libpulseaudio
      libsecret
      libuuid
      pciutils
      pipewire
      systemd
      wayland
      libxtst # in the official Depends (libxtst6); dlopen'd
    ];

    # Not `dpkg-deb -x`: chrome-sandbox is recorded SUID (rwsr-xr-x) in
    # data.tar and tar's mode-restore fails inside the build sandbox.
    # --no-same-permissions applies the umask instead, dropping the SUID
    # bit that the store couldn't represent anyway.
    unpackPhase = ''
      runHook preUnpack
      dpkg-deb --fsys-tarfile "$src" \
        | tar -x --no-same-owner --no-same-permissions
      runHook postUnpack
    '';

    dontConfigure = true;
    dontBuild = true;

    # The bundled ELFs are already stripped upstream; re-stripping a
    # ~160 MB Electron binary is slow and buys nothing.
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      # Ship the official install tree as-is:
      #   lib/claude-desktop/…    bare co-located app tree
      #   share/applications, icons/  consumed by claude-desktop-fhs
      # The .desktop uses a PATH-relative `Exec=claude-desktop %U`, so it
      # resolves the wrapper from a profile or the FHS env, no substitution.
      #
      # Chromium's co-located libvulkan.so.1 is the stock Khronos loader; it
      # searches the standard FHS ICD dirs, which are empty on NixOS, and
      # falls back to SwiftShader. The loader keys on env vars and fixed
      # filesystem paths, not DT_RUNPATH, so VK_ADD_DRIVER_FILES is the only
      # knob. It is additive (prepended to, not replacing, the normal
      # search) and thus dangling-safe.
      mkdir -p $out
      cp -a usr/lib usr/share $out/
      makeWrapper $out/lib/claude-desktop/claude-desktop \
        $out/bin/claude-desktop \
        --prefix VK_ADD_DRIVER_FILES : \
          "${addDriverRunpath.driverLink}/share/vulkan/icd.d"

      runHook postInstall
    '';

    # chrome-sandbox ships SUID in the official .deb, but the Nix store
    # cannot carry SUID bits. On kernels with unprivileged user namespaces
    # enabled (the NixOS default), Chromium prefers the namespace sandbox
    # and never invokes the SUID helper, so we ship it 0755 and do NOT
    # weaken sandboxing with --no-sandbox anywhere. Same stance as
    # nixpkgs' signal-desktop/slack.
    #
    # autoPatchelf resolves the bundled co-located libs (libffmpeg.so,
    # libEGL.so, libGLESv2.so, libvk_swiftshader.so, libvulkan.so.1) from
    # the output tree itself; the explicit search path is belt and braces
    # since the ELF's upstream RPATH is `$ORIGIN`.
    #
    # cowork-linux-helper is static Go — autoPatchelf skips it. virtiofsd
    # and chrome-native-host are glibc >= 2.34 (fine on any current
    # nixpkgs) and their DT_NEEDED are covered by buildInputs.
    preFixup = ''
      addAutoPatchelfSearchPath "$out/lib/claude-desktop"
    '';

    # Chromium's bundled ANGLE dlopen()s the glvnd dispatcher libEGL.so.1
    # by bare soname at GPU-init time. A dlopen resolves against the
    # *calling* object's runpath, and the co-located libs carry only their
    # own DT_NEEDED there — not libGL — so the dispatcher is unfindable
    # without inserting the glvnd driver dir. appendRunpaths adds these to
    # every patched ELF's runpath (runtimeDependencies would not:
    # autoPatchelf applies those to executables only, missing the .so that
    # issues the dlopen). Runpath, not a LD_LIBRARY_PATH wrapper, so the
    # driver libs don't leak into the env of the MCP servers the app spawns.
    appendRunpaths = [
      "${lib.getLib libGL}/lib"
      "${addDriverRunpath.driverLink}/lib"
    ];

    meta = {
      description = "Claude Desktop for Linux (unpacked official .deb)";
      homepage = "https://claude.ai";
      downloadPage = "https://downloads.claude.ai/claude-desktop/apt/stable";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = lib.platforms.linux;
      mainProgram = "claude-desktop";
    };
  }
