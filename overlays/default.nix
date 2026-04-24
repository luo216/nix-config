{ inputs, ... }:
{
  # Custom packages from the pkgs directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # Override or patch existing packages
  # Example: override a package version or add a patch
  # modifications = final: prev: {
  #   example = prev.example.overrideAttrs (old: rec {
  #     version = "1.2.3";
  #     src = prev.fetchFromGitHub {
  #       owner = "example";
  #       repo = "example";
  #       rev = version;
  #       hash = "sha256-...";
  #     };
  #   });
  # };

  # Unstable nixpkgs accessible via pkgs.unstable
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}