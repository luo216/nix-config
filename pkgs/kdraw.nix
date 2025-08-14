# 奎享雕刻 (kdraw) — 奎享科技写字机器人上位机软件。
#
# 上游只提供 deb，且不在 nixpkgs 中。包体是 jpackage 风格的自带 JRE 应用：
# 启动器是一个原生 ELF，内嵌 Java 22 运行时；应用 class 文件被加密，靠
# libkdrawLoader_kylin_x86.so 这个 JVMTI agent 在运行时解密，因此必须连同
# 内嵌 JRE 一起原样保留，不能换成 nixpkgs 的 JDK。
#
# 串口通信走 jSerialComm/jssc，依赖内核自带的 ch341 驱动，无需厂商驱动。
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  alsa-lib,
  libbsd,
  libgcc,
  fontconfig,
  freetype,
  libpng,
  zlib,
  xorg,
  xdg-utils,
}: let
  pname = "kdraw";
  version = "3.9.8";

  # 应用硬编码 /opt/kdraw：jpackage 的 .cfg 里 agentpath 和上游 desktop 文件的
  # Exec 都是绝对路径。NixOS 侧由模块把该路径软链到本包，这里不改写。
  appDir = "/opt/kdraw";

  desktopItem = makeDesktopItem {
    name = "kdraw";
    desktopName = "奎享雕刻";
    genericName = "写字机器人";
    comment = "奎享科技写字机器人专用软件";
    exec = "${appDir}/bin/奎享雕刻";
    icon = "kdraw";
    terminal = false;
    categories = ["Graphics" "Engineering"];
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://drawfont.oss-cn-beijing.aliyuncs.com/files/${pname}_${version}_amd64.deb";
      hash = "sha256-0zvwF7jaE6VOyuICN3UQi/ZmFylQEB0W/918reHLjU4=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    # 对应 deb 的 Depends 字段；autoPatchelfHook 需要它们来解析内嵌 JRE 里
    # 各 .so 的动态依赖（Java 的 AWT/X11/声音后端都是运行时 dlopen 的）。
    buildInputs = [
      alsa-lib
      libbsd
      # libkdrawLoader_kylin_x86.so（运行时解密 class 文件的 JVMTI agent）直接
      # 链接 libgcc_s.so.1，stdenv 自带的 libgcc 不参与 autoPatchelf 的搜索路径，
      # 需要显式加入。
      libgcc.lib
      freetype
      libpng
      zlib
      xorg.libX11
      xorg.libXau
      xorg.libxcb
      xorg.libXdmcp
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
    ];

    # 只在运行时才 dlopen，构建期看不到引用，需要显式声明。
    runtimeDependencies = [xdg-utils];

    # libawt_xawt.so 用 dlopen 加载 libfontconfig.so.1，既没有 DT_NEEDED 记录，也没有
    # .note.dlopen 段，autoPatchelfHook 因此完全察觉不到它，自然不会写进 RPATH。缺了它
    # AWT 会回退去读 JRE lib/ 下的 fontconfig.properties 映射表，而 jpackage 产出的运行时
    # 里根本没有这个文件，于是启动即抛：
    #   java.lang.RuntimeException: Fontconfig head is null
    #
    # 注意这里不能用 runtimeDependencies：hook 只在 file_is_dynamic_executable 为真时才把它
    # 拼进 RPATH，也就是只有主启动器拿得到，.so 拿不到 —— 而 dlopen 恰恰发生在 .so 里。
    # appendRunpaths 是无条件生效的，对每个被 patch 的文件都追加。
    #
    # 取 -lib 这个 output：fontconfig 的默认 output 只有 etc/ 和 share/，真正的
    # libfontconfig.so.1 在分离出来的 lib output 里。
    appendRunpaths = ["${lib.getLib fontconfig}/lib"];

    unpackPhase = ''
      runHook preUnpack
      mkdir unpacked
      dpkg -x $src unpacked
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r unpacked/opt $out

      # 上游 desktop 文件的 Categories=未知 不是合法值，GNOME 会直接忽略该条目，
      # 所以用 makeDesktopItem 重新生成一份。
      install -Dm644 ${desktopItem}/share/applications/kdraw.desktop \
        $out/share/applications/kdraw.desktop

      install -Dm644 $out${appDir}/lib/奎享雕刻.png \
        $out/share/icons/hicolor/128x128/apps/kdraw.png

      # 方便从终端启动；GUI 入口仍走 desktop 文件里的绝对路径。
      makeWrapper $out${appDir}/bin/奎享雕刻 $out/bin/kdraw

      runHook postInstall
    '';

    meta = {
      description = "奎享科技写字机器人上位机软件";
      homepage = "http://kvenjoy.com/";
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      # 厂商未声明许可证，且软件为闭源分发。
      license = lib.licenses.unfree;
      mainProgram = "kdraw";
    };
  }
