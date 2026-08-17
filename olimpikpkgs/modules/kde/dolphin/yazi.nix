{
  config,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.programs.dolphin;
in
{
  options.programs.dolphin = {
    yazi = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf (cfg.enable && cfg.yazi) {
    hm.programs.dolphin.actions.yazi-directory = {
      types = [
        "inode/directory"
      ];
      icon = "yazi";
      actions = {
        "yazi-open" = {
          name = "Open Yazi Here";
          exec = "alacritty --working-directory %f -e ${lib.getExe pkgs-s.yazi}";
        };
      };
    };
  };
}
