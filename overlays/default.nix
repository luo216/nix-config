# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Linux packages for kernel 6.13.1
    linuxPackages_6_13_1 = prev.linuxPackagesFor (
      prev.linux_6_6.override {
        argsOverride = rec {
          version = "6.13.1";
          modDirVersion = version;
          src = prev.fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "0smnalhyrgh5s3mw60q56r1jxj993ckfpldxvfrz27a7xb4gc4gh";
          };
        };
      }
    );

    dwm = prev.dwm.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [
        prev.xorg.libXcomposite
        prev.xorg.libXext
        prev.xorg.libXcursor
      ];
      src = prev.fetchFromGitHub {
        owner = "luo216";
        repo = "dwm";
        rev = "master";
        sha256 = "sha256-bJmFGsBB3IvdnvkVJPqNQbCYumAVmB3CvfDkkQMb66Y=";
      };
    });

  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
