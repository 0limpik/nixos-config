{
  config,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.my.office;
in
{
  options.my.office = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      packages = [
        pkgs-s.libreoffice-qt
        pkgs-s.hunspell
        pkgs-s.hyphenDicts.en_US
        pkgs-s.hyphenDicts.ru_RU
      ];
    in
    {
      os.environment.systemPackages = packages;
      hm.home.packages = packages;
    }
  );
}
