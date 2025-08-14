{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda";  # KVM/QEMU 虚拟机使用 /dev/vda 作为主磁盘
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          swap = {
            size = "4G";  # VM 使用较小的交换分区
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
