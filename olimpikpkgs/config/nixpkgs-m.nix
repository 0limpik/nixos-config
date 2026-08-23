args: pkgs:
let
  config = import ./nixpkgs.nix { inherit (pkgs) lib; inherit args; };
in
import pkgs {
  inherit (args) system;
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
