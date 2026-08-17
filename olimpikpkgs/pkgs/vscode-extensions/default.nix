{
  lib,
  callPackage,
}:
let
  mkExtension = callPackage ./extension.nix { };
in
(lib.mapAttrs (
  publisher: extensions:
  (lib.mapAttrs (
    name: value:
    mkExtension {
      publisher = publisher;
      name = name;
      inherit (value) version hash;
      location = "./pkgs/vscode-extensions/extensions.nix";
    }
  ) extensions)
) (import ./extensions.nix))
// {
  inherit mkExtension;
}
