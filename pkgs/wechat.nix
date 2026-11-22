{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "wechat";
  version = "4.1.1.4";

  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    hash = "sha256-ZbFSuutgutjU8bjlq/gAse/WHkKUUh1pQFgQFos/wsM=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    # 自 4.1.1.4 起上游 AppImage 改成了「安装器 + payload.tar」结构：AppRun 需要
    # pkexec 把 payload 安装到 /opt，无法在只读的 Nix store 中运行。这里直接解开
    # payload，并用一个只负责 exec 的 AppRun 代替原安装器。
    postExtract = ''
      tar -xf "$out/wechat-payload.tar" -C "$out"
      rm -f "$out/wechat-payload.tar" "$out/wechat-payload.sha256" "$out/install-apparmor.sh"

      cat > "$out/AppRun" <<'EOF'
#!/bin/sh
APPDIR="$(dirname "$(readlink -f "$0")")"
export APPDIR
exec "$APPDIR/wechat" "$@"
EOF
      chmod +x "$out/AppRun"
    '';
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;

    src = appimageContents;

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/wechat.desktop $out/share/applications/
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

      substituteInPlace $out/share/applications/wechat.desktop --replace-fail AppRun wechat
    '';

    meta = with lib; {
      description = "WeChat desktop client packaged from the upstream AppImage";
      homepage = "https://linux.weixin.qq.com/";
      license = licenses.unfreeRedistributable;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "wechat";
    };
  }
