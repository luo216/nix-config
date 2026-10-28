{
  hmcl,
  makeWrapper,
  symlinkJoin,
}:
symlinkJoin {
  name = "hmcl-nvidia-${hmcl.version}";
  paths = [hmcl];
  nativeBuildInputs = [makeWrapper];

  postBuild = ''
    wrapProgram $out/bin/hmcl \
      --set __NV_PRIME_RENDER_OFFLOAD 1 \
      --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
      --set __GLX_VENDOR_LIBRARY_NAME nvidia \
      --set __VK_LAYER_NV_optimus NVIDIA_only
  '';

  inherit (hmcl) meta;
}
