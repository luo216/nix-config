{
  # ventoy in nixpkgs is marked insecure because upstream ships binary blobs
  # with unresolved trust and licensing concerns. Keep this only while the
  # system still installs ventoy.
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];
}
