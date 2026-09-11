# Claude Desktop for Linux, unpacked from Anthropic's official .deb.
#
# The official tree ships bare co-located at usr/lib/claude-desktop/
# {claude-desktop, chrome-sandbox, resources/}, so we copy it whole — the
# ELF is a real file, never a symlink — and /proc/self/exe resolves inside
# this store path, which keeps process.resourcesPath correct by
# construction. No nixpkgs electron, no resourcesPath hack.
#
# Cowork is deliberately NOT supported here. The app bundles its own
# cowork-linux-helper and virtiofsd under resources/, but coworkd boots a
# real qemu/KVM guest and gates that on a qemu-system-x86_64 on PATH, an
# OVMF firmware pair under /usr/share/OVMF, and virtiofsd at
# /usr/bin/virtiofsd or /usr/libexec/virtiofsd. None of those exist for a
# plain Nix profile install, which is the point: no buildFHSEnv wrapper, no
# qemu/OVMF/virtiofsd in the closure, no kvm group membership and no
# vhost_vsock module. Chat, Claude Code and MCP servers work; the VM-backed
# cowork feature simply reports itself unavailable.
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
  # dlopen'd by the Electron main process / its bundled libvulkan.so.1 at
  # runtime (not in DT_NEEDED). runtimeDependencies lands these on the main
  # ELF's runpath; the co-located ANGLE/vulkan libs issue their own dlopen
  # and need libGL on every ELF's runpath instead (see appendRunpaths).
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
  # Latest apt "stable" entry; the pool keeps every release, so this is the
  # only version pinned.
  version = "1.52386.0";

  poolBase = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop";
in
  stdenv.mkDerivation {
    pname = "claude-desktop";
    inherit version;

    src = fetchurl {
      url = "${poolBase}/claude-desktop_${version}_amd64.deb";
      hash = "sha256-nF0RPqLDHA1PYHXALmGAv0q1PTVza5pJfODoT2LpZUs=";
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
    # ~220 MB Electron binary is slow and buys nothing.
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      # Ship the official install tree as-is:
      #   lib/claude-desktop/…    bare co-located app tree
      #   share/applications, icons/  for the desktop entry
      # The .deb's usr/bin/claude-desktop symlink is intentionally not
      # copied — $out/bin/claude-desktop below is the wrapper.
      #
      # The .desktop uses a PATH-relative `Exec=claude-desktop %U`, so it
      # resolves the wrapper from the profile, no substitution.
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
    # enabled (the NixOS default — no apparmor_restrict_unprivileged_userns,
    # unlike Ubuntu 24.04+), Chromium prefers the namespace sandbox and
    # never invokes the SUID helper, so we ship it 0755 and do NOT weaken
    # sandboxing with --no-sandbox anywhere. Same stance as nixpkgs'
    # signal-desktop/slack.
    #
    # autoPatchelf resolves the bundled co-located libs (libffmpeg.so,
    # libvk_swiftshader.so, libvulkan.so.1) from the output tree itself; the
    # explicit search path is belt and braces since the ELF's upstream
    # RPATH is `$ORIGIN`.
    #
    # cowork-linux-helper is static Go — autoPatchelf skips it, and nothing
    # short of the VM stack described at the top would run it.
    preFixup = ''
      addAutoPatchelfSearchPath "$out/lib/claude-desktop"
    '';

    # The bundled libvulkan.so.1 / libvk_swiftshader.so dlopen() the glvnd
    # dispatcher libEGL.so.1 by bare soname at GPU-init time. A dlopen
    # resolves against the *calling* object's runpath, and the co-located
    # libs carry only their own DT_NEEDED there — not libGL — so the
    # dispatcher is unfindable without inserting the glvnd driver dir.
    # appendRunpaths adds these to every patched ELF's runpath
    # (runtimeDependencies would not: autoPatchelf applies those to
    # executables only, missing the .so that issues the dlopen). Runpath,
    # not a LD_LIBRARY_PATH wrapper, so the driver libs don't leak into the
    # env of the MCP servers the app spawns.
    appendRunpaths = [
      "${lib.getLib libGL}/lib"
      "${addDriverRunpath.driverLink}/lib"
    ];

    meta = {
      description = "Claude Desktop for Linux (unpacked official .deb, no Cowork VM stack)";
      homepage = "https://claude.ai";
      downloadPage = "https://downloads.claude.ai/claude-desktop/apt/stable";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = lib.platforms.linux;
      mainProgram = "claude-desktop";
    };
  }
