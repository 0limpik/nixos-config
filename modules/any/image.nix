{
  config,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.my.image;
in
{
  options.my.image = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    comfy-ui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib-o.mkIf cfg.enable {
    any = {
      nix.settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://comfyui.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
    hm = {
      home.packages = [
        pkgs-s.xnviewmp
      ];
    };
  };
}
