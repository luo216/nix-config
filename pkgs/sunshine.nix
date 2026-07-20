{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  autoPatchelfHook,
  autoAddDriverRunpath,
  makeWrapper,
  buildNpmPackage,
  fetchNpmDeps,
  nixosTests,
  cmake,
  avahi,
  libevdev,
  libpulseaudio,
  libxtst,
  libxrandr,
  libxi,
  libxfixes,
  libxdmcp,
  libx11,
  libxcb,
  openssl,
  libopus,
  boost,
  pkg-config,
  libdrm,
  wayland,
  wayland-scanner,
  libffi,
  libcap,
  libgbm,
  curl,
  pcre,
  pcre2,
  python3,
  libuuid,
  libselinux,
  libsepol,
  libthai,
  libdatrie,
  libxkbcommon,
  libepoxy,
  libva,
  libvdpau,
  libglvnd,
  numactl,
  amf-headers,
  svt-av1,
  vulkan-loader,
  libappindicator,
  libnotify,
  miniupnpc,
  nlohmann_json,
  pipewire,
  config,
  coreutils,
  qt6,
  udevCheckHook,
  cudaSupport ? config.cudaSupport,
  cudaPackages ? {},
  apple-sdk_15,
}: let
  inherit (stdenv.hostPlatform) isDarwin isLinux;
  stdenv' =
    if cudaSupport
    then cudaPackages.backendStdenv
    else stdenv;
  ffmpegPreparedBinaries = fetchzip {
    url = "https://github.com/LizardByte/build-deps/releases/download/v2026.516.30821/Linux-x86_64-ffmpeg.tar.gz";
    hash = "sha256-VT+4qP2FaizCoIBBbBkzbYw4YOvGhuBUoZxWL0IYVZo=";
  };
  pythonForBuild = python3.withPackages (ps:
    with ps; [
      jinja2
      pip
      setuptools
    ]);
in
  stdenv'.mkDerivation (finalAttrs: {
    pname = "sunshine";
    version = "2026.704.34109";

    src = fetchFromGitHub {
      owner = "LizardByte";
      repo = "Sunshine";
      tag = "v${finalAttrs.version}";
      hash = "sha256-GNVoj62VRq6fKAezrQRU9r6sYEHN8kjzmEwpo/kBXJA=";
      fetchSubmodules = true;
    };

    ui = buildNpmPackage rec {
      inherit (finalAttrs) src version;
      pname = "sunshine-ui";
      npmDeps = fetchNpmDeps {
        inherit (finalAttrs) src;
        hash = "sha256-A/l/gBLpKp8lw1L2W+4JYn5WzhLAmAWEXRwm2TwZlno=";
      };

      postPatch = ''
        cp ${npmDeps}/package-lock.json ./package-lock.json
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -a . "$out"/
        runHook postInstall
      '';
    };

    postPatch =
      ''
        substituteInPlace cmake/targets/common.cmake \
          --replace-fail 'find_program(NPM npm REQUIRED)' ""

        substituteInPlace cmake/dependencies/Boost_Sunshine.cmake \
          --replace-fail 'set(BOOST_VERSION "1.89.0")' 'set(BOOST_VERSION "${boost.version}")'
      ''
      + lib.optionalString isLinux ''
        substituteInPlace cmake/packaging/linux.cmake \
          --replace-fail 'find_package(Systemd)' "" \
          --replace-fail 'find_package(Udev)' ""

        substituteInPlace packaging/linux/dev.lizardbyte.app.Sunshine.desktop \
          --subst-var-by PROJECT_NAME 'Sunshine' \
          --subst-var-by PROJECT_DESCRIPTION 'Self-hosted game stream host for Moonlight' \
          --subst-var-by SUNSHINE_DESKTOP_ICON 'sunshine' \
          --subst-var-by CMAKE_INSTALL_FULL_DATAROOTDIR "$out/share" \
          --replace-fail '/usr/bin/env systemctl start --u app-@PROJECT_FQDN@' 'sunshine'

        substituteInPlace packaging/linux/app-dev.lizardbyte.app.Sunshine.service.in \
          --subst-var-by PROJECT_DESCRIPTION 'Self-hosted game stream host for Moonlight' \
          --subst-var-by SUNSHINE_EXECUTABLE_PATH $out/bin/sunshine \
          --replace-fail '/bin/sleep' '${coreutils}/bin/sleep'
      '';

    nativeBuildInputs =
      [
        cmake
        pkg-config
        pythonForBuild
        makeWrapper
      ]
      ++ lib.optionals isLinux [
        wayland-scanner
        autoPatchelfHook
        qt6.wrapQtAppsHook
      ]
      ++ lib.optionals cudaSupport [
        autoAddDriverRunpath
        cudaPackages.cuda_nvcc
        (lib.getDev cudaPackages.cuda_cudart)
      ];

    buildInputs =
      [
        boost
        curl
        miniupnpc
        nlohmann_json
        openssl
        libopus
      ]
      ++ lib.optionals isLinux [
        avahi
        libevdev
        libpulseaudio
        libx11
        libxcb
        libxfixes
        libxrandr
        libxtst
        libxi
        libdrm
        wayland
        libffi
        libevdev
        libcap
        libdrm
        pcre
        pcre2
        libuuid
        libselinux
        libsepol
        libthai
        libdatrie
        libxdmcp
        libxkbcommon
        libepoxy
        libva
        libvdpau
        numactl
        libgbm
        amf-headers
        svt-av1
        libappindicator
        libnotify
        pipewire
        qt6.qtbase
        qt6.qtsvg
      ]
      ++ lib.optionals cudaSupport [
        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
      ]
      ++ lib.optionals isDarwin [
        apple-sdk_15
      ];

    runtimeDependencies = lib.optionals isLinux [
      avahi
      libgbm
      libxrandr
      libxcb
      libglvnd
    ];

    cmakeFlags =
      [
        "-Wno-dev"
        (lib.cmakeBool "BOOST_USE_STATIC" false)
        (lib.cmakeBool "BUILD_DOCS" false)
        (lib.cmakeBool "SUNSHINE_ENABLE_VULKAN" false)
        (lib.cmakeFeature "FFMPEG_PREPARED_BINARIES" "${ffmpegPreparedBinaries}")
        (lib.cmakeFeature "SUNSHINE_PUBLISHER_NAME" "nixpkgs")
        (lib.cmakeFeature "SUNSHINE_PUBLISHER_WEBSITE" "https://nixos.org")
        (lib.cmakeFeature "SUNSHINE_PUBLISHER_ISSUE_URL" "https://github.com/NixOS/nixpkgs/issues")
      ]
      ++ lib.optionals isLinux [
        (lib.cmakeBool "UDEV_FOUND" true)
        (lib.cmakeBool "SYSTEMD_FOUND" true)
        (lib.cmakeFeature "UDEV_RULES_INSTALL_DIR" "lib/udev/rules.d")
        (lib.cmakeFeature "SYSTEMD_USER_UNIT_INSTALL_DIR" "lib/systemd/user")
        (lib.cmakeFeature "SYSTEMD_MODULES_LOAD_DIR" "lib/modules-load.d")
      ]
      ++ lib.optionals (!cudaSupport) [
        (lib.cmakeBool "SUNSHINE_ENABLE_CUDA" false)
      ]
      ++ lib.optionals isDarwin [
        (lib.cmakeFeature "CMAKE_CXX_STANDARD" "23")
        (lib.cmakeFeature "OPENSSL_ROOT_DIR" "${openssl.dev}")
        (lib.cmakeFeature "SUNSHINE_ASSETS_DIR" "sunshine/assets")
        (lib.cmakeBool "SUNSHINE_BUILD_HOMEBREW" true)
      ];

    env = {
      BUILD_VERSION = "${finalAttrs.version}";
      BRANCH = "master";
      COMMIT = "";
    };

    preBuild = ''
      cp -r ${finalAttrs.ui}/build ../
    '';

    buildFlags = ["sunshine"];

    installPhase = ''
      runHook preInstall
      cmake --install .
      runHook postInstall
    '';

    postInstall = lib.optionalString isLinux ''
      install -Dm644 ../packaging/linux/dev.lizardbyte.app.Sunshine.desktop $out/share/applications/dev.lizardbyte.app.Sunshine.desktop
    '';

    postFixup = lib.optionalString cudaSupport ''
      wrapProgram $out/bin/sunshine \
        --set LD_LIBRARY_PATH ${lib.makeLibraryPath [vulkan-loader]}
    '';

    doInstallCheck = isLinux;
    nativeInstallCheckInputs = lib.optionals isLinux [udevCheckHook];

    passthru = {
      tests = lib.optionalAttrs isLinux {
        inherit (nixosTests) sunshine;
      };
    };

    meta = {
      description = "Game stream host for Moonlight";
      homepage = "https://github.com/LizardByte/Sunshine";
      license = lib.licenses.gpl3Only;
      mainProgram = "sunshine";
      maintainers = with lib.maintainers; [
        devusb
        anish
      ];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  })
