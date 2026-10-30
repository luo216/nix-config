# vps — BIOS boot, single virtio disk /dev/vda
{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          # SeaBIOS cannot read an ESP; grub loads from the BIOS boot partition
          boot = {
            size = "1M";
            type = "EF02";
          };

          swap = {
            size = "2G";
            content.type = "swap";
          };

          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
