{
  # Placeholder disko layout for the local sec-lab VM.
  # This file exists to keep the repository's host structure uniform.
  # The local build-vm workflow is VM-oriented and does not treat this as a
  # carefully modeled physical disk plan.
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/vda";
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
            size = "4G";
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
