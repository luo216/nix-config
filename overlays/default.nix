{inputs, ...}: {
  # Custom packages from the pkgs directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # Override or patch existing packages
  modifications = final: prev: {
    stegsolve =
      prev.stegsolve.overrideAttrs
      (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.makeWrapper];

        postFixup =
          (old.postFixup or "")
          + ''
            mv $out/bin/stegsolve $out/bin/.stegsolve-wrapped
            makeWrapper $out/bin/.stegsolve-wrapped $out/bin/stegsolve \
              --set _JAVA_OPTIONS "-Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -Dawt.useSystemAAFontSettings=on -Dswing.plaf.metal.controlFont=Dialog-12 -Dswing.plaf.metal.userFont=Dialog-12 -Dswing.plaf.metal.systemFont=Dialog-12"
          '';
      });
  };

  # Unstable nixpkgs accessible via pkgs.unstable
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
