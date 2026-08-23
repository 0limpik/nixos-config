{
  lib,
  args,
}:
{
  allowUnfreePredicate =
    name: list: pkg:
    lib.trace "${name} | u | ${(lib.getName pkg)}" (lib.elem (lib.getName pkg) list);
  allowInsecurePredicate =
    name: list: pkg:
    lib.trace "${name} | i | ${(lib.getName pkg)}" (lib.elem (lib.getName pkg) list);
  overlay =
    final: prev:
    (
      {
        lib = prev.lib // {
          maintainers = prev.lib.maintainers // {
            olimpik = {
              email = "olimpik.net@gmail.com";
              name = "Evgeniy Galyuta";
              github = "0limpik";
            };
          };
        };
      }
      // (lib.optionalAttrs ((args.nix-update-script or null) != null) {
        inherit (args) nix-update-script;
      })
    );
}
