system: pkgs:
let
  config = import ./nixpkgs.nix { inherit (pkgs) lib; };
in
import pkgs {
  inherit system;
  config = {
    allowUnfreePredicate = config.allowUnfreePredicate "m" [
      "discord"
      "nomachine-client"
    ];
  };
  overlays = [
    config.overlay
  ];
}
