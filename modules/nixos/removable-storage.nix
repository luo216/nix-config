{
  # 外接存储（U 盘、移动硬盘）的驱动与修复工具。
  #
  # 内核里 exfat/ntfs/vfat 驱动本身是现成的，这里补的是用户态部分：
  # exfatprogs 提供 fsck.exfat、ntfs3g 提供 ntfsfix，缺了就没法修脏卷
  # （dosfstools 的 fsck.vfat 本来就默认带）。
  boot.supportedFilesystems = [ "exfat" "ntfs" "vfat" ];
}
