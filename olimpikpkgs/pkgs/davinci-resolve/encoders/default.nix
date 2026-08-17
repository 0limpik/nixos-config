{
  lib,
  newScope,
  pkgs,
  callPackage,
  uniform-names ? false,
}:
let
  options = { inherit uniform-names; };
  encoders = builtins.mapAttrs (
    name: dvcp:
    encoder (
      {
        encoder-name = name;
        inherit dvcp;
      }
      // lib.optionalAttrs (dvcp ? name) {
        inherit (dvcp) name;
      }
      // lib.optionalAttrs (dvcp ? pname) {
        inherit (dvcp) pname;
      }
      // lib.optionalAttrs (dvcp ? version) {
        inherit (dvcp) version;
      }
    )
  ) (import ./encoders.nix { callPackage = callPackageScope; });
  callPackageScope = newScope (pkgs // options);
  encoder = callPackage ./encoder.nix { };
in
options // encoders
