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
    inherit bus slot function;
  };

  domainDef = {
    type = "kvm";
    name = "win11";
    uuid = "c1a2b3d4-e5f6-7890-abcd-ef1234567890";
    memory = {count = 16; unit = "GiB";};
    vcpu = {
      placement = "static";
      count = 8;
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
        path = "/data/vm/nvram/win11_OVMF_VARS.fd";
      };
      boot = [{dev = "hd";} {dev = "cdrom";}];
      bootmenu.enable = true;
    };
    features = {
      acpi = {};
      apic = {};
      hyperv = {
        relaxed.state = true;
        vapic.state = true;
        spinlocks = {state = true; retries = 8191;};
        vendor_id = {state = true; value = "GenuineIntel";};
        vpindex.state = true;
        runtime.state = true;
        synic.state = true;
        stimer.state = true;
        frequencies.state = true;
        tlbflush.state = true;
        ipi.state = true;
        evmcs.state = true;
        reset.state = true;
      };
      kvm.hidden.state = true;
      vmport.state = false;
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
        {name = "rtc"; tickpolicy = "catchup";}
        {name = "pit"; tickpolicy = "delay";}
        {name = "hpet"; present = false;}
        {name = "hypervclock"; present = true;}
      ];
    };
    on_poweroff = "destroy";
    on_reboot = "destroy";
    on_crash = "destroy";
    pm = {
      suspend-to-mem.enabled = false;
      suspend-to-disk.enabled = false;
    };
    devices = {
      emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";
      controller = [
        {type = "usb"; index = 0; model = "qemu-xhci"; ports = 15;}
        {type = "pci"; index = 0; model = "pcie-root";}
        {type = "pci"; index = 1; model = "pcie-root-port"; target = {chassis = 1; port = 16;};}
        {type = "pci"; index = 2; model = "pcie-root-port"; target = {chassis = 2; port = 17;};}
        {type = "pci"; index = 3; model = "pcie-root-port"; target = {chassis = 3; port = 18;};}
        {type = "pci"; index = 4; model = "pcie-root-port"; target = {chassis = 4; port = 19;};}
      ];
      input = [
        {type = "tablet"; bus = "usb";}
        {type = "keyboard"; bus = "usb";}
      ];
      interface = {
        type = "user";
        mac.address = "52:54:00:12:34:56";
        model.type = "e1000e";
      };
      tpm = {
        model = "tpm-crb";
        backend = {type = "emulator"; version = "2.0";};
      };
      video = {
        model = {type = "qxl"; heads = 1; primary = true;};
      };
      graphics = {
        type = "spice";
        autoport = true;
        listen = {type = "address"; address = "127.0.0.1";};
        image.compression = false;
      };
      sound.model = "ich9";
      channel = [
        {
          type = "unix";
          target = {type = "virtio"; name = "org.qemu.guest_agent.0";};
        }
        {
          type = "spicevmc";
          target = {type = "virtio"; name = "com.redhat.spice.0";};
        }
      ];
      redirdev = [
        {bus = "usb"; type = "spicevmc";}
        {bus = "usb"; type = "spicevmc";}
      ];
      console.type = "pty";
      memballoon.model = "virtio";
      hostdev = [
        {
          mode = "subsystem";
          type = "pci";
          managed = true;
          source.address = pciAddr 2 0 0;
          address = pciAddr 3 0 0;
        }
      ];
    };
  };
in {
  options.services.windows-vm.enable = lib.mkEnableOption "Windows 11 VM with NVMe passthrough";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirt.enable = true;
    virtualisation.libvirt.swtpm.enable = true;

    virtualisation.libvirt.connections."qemu:///system".domains = [
      {
        definition = inputs.NixVirt.lib.domain.writeXML domainDef;
        active = false;
      }
    ];
  };
}
