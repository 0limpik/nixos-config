{
  config,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.my.windows;
in
{
  options.my.windows = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      packages = [
        pkgs-s.wineWow64Packages.stable
        pkgs-s.winetricks
      ];
    in
    {
      os = {
        environment.systemPackages = packages ++ [
          pkgs-s.clamav
        ];
        services.clamav = {
          daemon.enable = true;
          updater = {
            enable = true;
            settings = {
              PrivateMirror = [
                "https://clamav-mirror.ru/"
                "https://mirror.truenetwork.ru/clamav/"
              ];
              ScriptedUpdates = false;
            };
          };
        };
      };
      hm.home.packages = packages;
    }
  );
}
