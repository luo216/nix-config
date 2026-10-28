# Package set & formatter — one per system.
{
  forAllSystems,
  pkgsFor,
}: {
  packages = forAllSystems (system: import ../pkgs (pkgsFor system));
  formatter = forAllSystems (
    system: let
      pkgs = pkgsFor system;
    in
      pkgs.writeShellApplication {
        name = "nix-config-format";
        runtimeInputs = [
          pkgs.alejandra
          pkgs.git
        ];
        text = ''
          mapfile -d $'\0' files < <(git ls-files -z --cached --others --exclude-standard -- '*.nix')
            exec alejandra "$@" "''${files[@]}"
        '';
      }
  );
}
