# Pixelbook Go Audio Support Module
#
# Pixelbook Go (Atlas, CML-LP) uses Intel Audio DSP with:
#   - Speaker: Maxim max98373
#   - Headset codec: Dialog da7219
#   - Digital mic: DMIC
#
# Two driver paths are available:
#   - SOF (default): uses upstream sof-firmware, well-maintained, works with pipewire
#   - AVS (legacy): uses custom avs-topology from templates/, more experimental
#
# dsp_driver values for snd-intel-dspcfg:
#   1 = SST (Atom), 2 = HDAudio legacy, 3 = SOF, 4 = AVS
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.hardware.pixelbook-go-audio;

  # AVS topology from local archive (only needed for AVS driver path)
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
    enable = mkEnableOption "Pixelbook Go audio support";

    driver = mkOption {
      type = types.enum [ "sof" "avs" ];
      default = "sof";
      description = "Audio DSP driver: 'sof' (upstream, recommended) or 'avs' (legacy, requires custom topology)";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Common: firmware + kernel modules + pipewire tuning
      hardware.firmware = with pkgs; [
        sof-firmware
      ];

      environment.systemPackages = with pkgs; [
        alsa-utils
      ];

      boot = {
        kernelModules = [
          "snd-soc-hda-codec-hdmi"
          "snd-soc-dmic"
        ];
      };

      # Increase ALSA headroom to prevent buffer underruns on AVS hardware
      services.pipewire.wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-increase-headroom.conf" ''
          monitor.alsa.rules = [
            {
              matches = [
                { node.name = "~alsa_output.*" }
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
    }

    # SOF driver path (default)
    (mkIf (cfg.driver == "sof") {
      boot = {
        kernelModules = [
          "snd-sof-pci-intel-cml"
        ];
        extraModprobeConfig = ''
          options snd-intel-dspcfg dsp_driver=3
        '';
      };
    })

    # AVS driver path (legacy)
    (mkIf (cfg.driver == "avs") {
      hardware.firmware = [ avs-topology ];

      boot = {
        kernelModules = [
          "snd-soc-avs"
        ];
        extraModprobeConfig = ''
          options snd-intel-dspcfg dsp_driver=4
          options snd-soc-avs ignore_fw_version=1
          options snd-soc-avs obsolete_card_names=1
        '';
      };

      environment.sessionVariables = {
        ALSA_AUDIO_OUT = mkForce "hw:avsmax98373,1";
        ALSA_AUDIO_IN = mkForce "hw:avsdmic,2";
      };
    })
  ]);
}
