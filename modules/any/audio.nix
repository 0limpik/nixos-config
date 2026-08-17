{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-u,
  ...
}:
let
  cfg = config.my.audio;
in
{
  options.my.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf cfg.enable {
    os = {
      environment.systemPackages = [
        pkgs-s.crosspipe
        pkgs-u.pipewire
        pkgs-u.wireplumber
        pkgs-u.alsa-utils
      ];
    };
    hm = {
      home.packages = [
        pkgs-s.crosspipe
      ];
    };
  };

}
