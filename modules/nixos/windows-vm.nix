{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.services.windows-vm;

  pciAddr = bus: slot: function: {
    type = "pci";
    domain = 0;
    bus = bus;
    slot = slot;
    inherit function;
  };

  domainDef = {
    type = "kvm";
    name = "windows";
    uuid = "c1a2b3d4-e5f6-7890-abcd-ef1234567890";
    memory = {
      count =
        if lib.hasSuffix "G" cfg.memory
        then lib.toInt (lib.removeSuffix "G" cfg.memory)
        else if lib.hasSuffix "M" cfg.memory
        then lib.toInt (lib.removeSuffix "M" cfg.memory)
        else lib.toInt cfg.memory;
      unit =
        if lib.hasSuffix "G" cfg.memory
        then "GiB"
        else "MiB";
    };
    vcpu = {
      placement = "static";
      count = cfg.vcpu;
    };
    os = {
      type = "hvm";
      arch = "x86_64";
      machine = "q35";
      loader = {
        readonly = true;
        type = "pflash";
        path = "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd";
      };
      nvram = {
        template = "/run/libvirt/nix-ovmf/edk2-i386-vars.fd";
        path = cfg.nvramPath;
      };
      boot = [{dev = "hd";} {dev = "cdrom";}];
      bootmenu = {enable = true;};
    };
    features = {
      acpi = {};
      apic = {};
      hyperv = {
        relaxed = {state = true;};
        vapic = {state = true;};
        spinlocks = {
          state = true;
          retries = 8191;
        };
        vendor_id = {
          state = true;
          value = "GenuineIntel";
        };
      };
      kvm = {hidden = {state = true;};};
    };
    cpu = {
      mode = "host-passthrough";
      check = "none";
      migratable = true;
      topology = {
        sockets = 1;
        dies = 1;
        cores = 4;
        threads = 2;
      };
    };
    clock = {
      offset = "localtime";
      timer = [
        {
          name = "rtc";
          tickpolicy = "catchup";
        }
        {
          name = "pit";
          tickpolicy = "delay";
        }
        {
          name = "hpet";
          present = false;
        }
      ];
    };
    on_poweroff = "destroy";
    on_reboot = "destroy";
    on_crash = "destroy";
    pm = {
      suspend-to-mem = {enabled = false;};
      suspend-to-disk = {enabled = false;};
    };
    devices = let
      hostdevList =
        lib.optional cfg.nvmePassthrough {
          mode = "subsystem";
          type = "pci";
          managed = true;
          source = {address = pciAddr 2 0 0;};
          address = pciAddr 1 0 0;
        }
        ++ lib.optionals cfg.dgpuPassthrough [
          {
            mode = "subsystem";
            type = "pci";
            managed = true;
            source = {address = pciAddr 1 0 0;};
            rom = {
              bar = false;
              file = cfg.romPath;
            };
            address = pciAddr 2 0 0 // {multifunction = true;};
          }
          {
            mode = "subsystem";
            type = "pci";
            managed = true;
            source = {address = pciAddr 1 0 1;};
            address = pciAddr 2 0 1;
          }
        ];
    in
      {
        emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";
        controller =
          [
            {
              type = "usb";
              index = 0;
              model = "qemu-xhci";
              ports = 15;
              address = pciAddr 0 7 0;
            }
            {
              type = "pci";
              index = 0;
              model = "pcie-root";
            }
            {
              type = "pci";
              index = 1;
              model = "pcie-root-port";
              address = pciAddr 0 1 0;
              target = {
                chassis = 1;
                port = 16;
              };
            }
          ]
          ++ lib.optional cfg.dgpuPassthrough {
            type = "pci";
            index = 2;
            model = "pcie-root-port";
            address = pciAddr 0 2 0;
            target = {
              chassis = 2;
              port = 17;
            };
          };
        input = [
          {
            type = "tablet";
            bus = "usb";
            address = {
              type = "usb";
              bus = 0;
              port = 1;
            };
          }
          {
            type = "keyboard";
            bus = "usb";
            address = {
              type = "usb";
              bus = 0;
              port = 2;
            };
          }
        ];
        interface = {
          type = "user";
          mac = {address = "52:54:00:12:34:56";};
          model = {type = "e1000e";};
          address = pciAddr 0 4 0;
        };
        tpm = {
          model = "tpm-crb";
          backend = {
            type = "emulator";
            version = "2.0";
          };
        };
        video = {
          model = {
            type = "virtio";
            heads = 1;
            primary = true;
            acceleration = {accel3d = cfg.glAcceleration;};
          };
          address = pciAddr 0 5 0;
        };
        graphics = {
          type = "spice";
          autoport = true;
          listen = {type = "none";};
          image = {compression = false;};
          gl = {enable = cfg.glAcceleration;};
        };
      }
      // lib.optionalAttrs (hostdevList != []) {
        hostdev = hostdevList;
      };
  };
in {
  options.services.windows-vm = {
    enable = lib.mkEnableOption "Windows VM";

    memory = lib.mkOption {
      type = lib.types.str;
      default = "16G";
      description = "VM memory (e.g. \"16G\", \"8192M\").";
    };

    vcpu = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8;
      description = "Number of virtual CPUs.";
    };

    nvmePassthrough = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Pass NVMe SSD (02:00.0) to the VM.";
    };

    dgpuPassthrough = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Pass NVIDIA dGPU (01:00.0 + 01:00.1) to the VM.
        Keep this disabled while collecting Windows fonts via the SPICE
        console; flip to true once the host is ready to give up the GPU.
      '';
    };

    romPath = lib.mkOption {
      type = lib.types.str;
      default = "/data/vm/roms/rtx3050_pcat.rom";
      description = "Path to NVIDIA GPU ROM file (used when dgpuPassthrough is enabled).";
    };

    glAcceleration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SPICE GL with virtio video 3D acceleration.";
    };

    nvramPath = lib.mkOption {
      type = lib.types.str;
      default = "/data/vm/nvram/windows_OVMF_VARS.fd";
      description = "Path to OVMF variables file.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirt.enable = true;
    virtualisation.libvirt.swtpm.enable = true;

    virtualisation.libvirt.connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML domainDef;
          active = false;
        }
      ];
    };
  };
}
