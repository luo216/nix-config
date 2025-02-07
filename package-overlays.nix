# 包覆盖配置文件
# 这个文件定义了从unstable版本获取的包
# 当稳定版本中某个包不存在或版本太旧时，可以在这里添加

{ nixpkgs-unstable }:

final: prev: {
  # 在这里添加需要从unstable获取的包
  
  # 示例：使用unstable版本的firefox（如果稳定版版本太旧）
  # firefox = nixpkgs-unstable.legacyPackages.x86_64-linux.firefox;
  
  # 示例：使用unstable版本的某个新工具
  # new-tool = nixpkgs-unstable.legacyPackages.x86_64-linux.new-tool;
  
  # 示例：使用unstable版本的开发工具
  # rust-analyzer = nixpkgs-unstable.legacyPackages.x86_64-linux.rust-analyzer;
  
  # 示例：使用unstable版本的某个应用
  # obsidian = nixpkgs-unstable.legacyPackages.x86_64-linux.obsidian;
  
  # 示例：使用unstable版本的某个库
  # python3Packages.new-library = nixpkgs-unstable.legacyPackages.x86_64-linux.python3Packages.new-library;
} 