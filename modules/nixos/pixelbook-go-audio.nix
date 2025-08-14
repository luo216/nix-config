# Pixelbook Go AVS Audio Support Module
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.hardware.pixelbook-go-audio;

  # AVS 拓扑文件
  avs-topology = pkgs.stdenv.mkDerivation {
    pname = "avs-topology";
    version = "2024.02";
    src = ../templates/chromebook-audio/avs-topology_2024.02.tar.gz;
    unpackPhase = ''
      mkdir -p source
      tar xf $src -C source
    '';
    installPhase = ''
      mkdir -p $out/lib/firmware/intel/avs
      cp -r source/avs-topology/lib/firmware/intel/avs/* $out/lib/firmware/intel/avs/
    '';
  };

in
{
  options.hardware.pixelbook-go-audio = {
    enable = mkEnableOption "Pixelbook Go AVS audio support";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        alsa-utils
        sof-firmware
      ];
      sessionVariables = {
        # Pixelbook Go 音频设备环境变量 (使用稳定的设备名称)
        ALSA_AUDIO_OUT = mkForce "hw:avsmax98373,1"; # 扬声器输出
        ALSA_AUDIO_IN = mkForce "hw:avsdmic,2"; # 数字麦克风输入
      };
    };

    # AVS 固件支持
    hardware = {
      firmware = [ avs-topology ];
      alsa.enable = true;
    };

    # 内核配置
    boot = {
      kernelModules = [
        "snd-soc-avs"
        "snd-soc-hda-codec-hdmi"
        "snd-soc-dmic"
      ];
      extraModprobeConfig = ''
        options snd-intel-dspcfg dsp_driver=4
        options snd-soc-avs ignore_fw_version=1
        options snd-soc-avs obsolete_card_names=1
      '';
    };

    services.pipewire.wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-increase-headroom.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              {
                node.name = "~alsa_output.*"
              }
            ]
            actions = {
              update-props = {
                api.alsa.headroom = 8192
              }
            }
          }
        ]
      '')
    ];
  };
}
