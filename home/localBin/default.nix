{ config, pkgs, ... }:

{
  home.file.".local/bin" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
  };
}
