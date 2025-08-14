{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.customLftp;
in {
  options.programs.customLftp = {
    enable = mkEnableOption "lftp, preconfigured for Chinese (GBK) FTP servers";

    package = mkOption {
      type = types.package;
      default = pkgs.lftp;
      defaultText = "pkgs.lftp";
      description = "The lftp package to use.";
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {"mirror:parallel-transfer-count" = "2";};
      description = "额外的 lftp 设置，追加在内置的中文编码配置之后（设置名不带 set）。";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."lftp/rc".text =
      concatStringsSep "\n" (builtins.map (kv: "set ${kv}") (
          [
            # 中文 FTP 服务器的目录/文件名是 GBK，不设这两项中文会乱码。
            "ftp:charset gbk"
            "file:charset utf-8"
            # 省考试院服务器（Serv-U）TLS 控制通道能握手，但数据连接会超时，
            # 只能走明文。服务端修好后可改成 yes 启用加密。
            "ftp:ssl-allow no"
            "net:timeout 20"
            "net:max-retries 3"
            "net:reconnect-interval-base 5"
          ]
          ++ mapAttrsToList (name: value: "${name} ${value}") cfg.settings
        ))
      + "\n";
  };
}
