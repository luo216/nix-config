# Package set & formatter — one per system.
{
  forAllSystems,
  pkgsFor,
}:
{
  packages = forAllSystems (system: import ../pkgs (pkgsFor system));
  formatter = forAllSystems (system: (pkgsFor system).alejandra);
}
