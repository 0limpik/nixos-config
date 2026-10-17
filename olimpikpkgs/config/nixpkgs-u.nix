args: pkgs:
let
  config = import ./nixpkgs.nix {
    inherit (pkgs) lib;
    inherit args;
  };
in
import pkgs {
  inherit (args) system;
  config = {
    allowUnfreePredicate = config.allowUnfreePredicate "u" [
      "clion-with-plugins"
      "clion"
      "ffmpeg-full"
      "amf"
      "amdenc"
      "git-fork"
      "winbox"
    ];
  };
  overlays = [
    config.overlay
  ];
  packageOverrides = pkgs: { } // (config.packageOverrides pkgs);

}
