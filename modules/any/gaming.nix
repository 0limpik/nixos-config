{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-u,
  pkgs-o,
  ...
}:
let
  cfg = config.my.gaming;
in
{
  options.my.gaming = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    steam = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    vr = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib-o.mkConfig {
        os = {
          environment.systemPackages = [
            pkgs-s.heroic
            pkgs-s.mangohud
            pkgs-s.protonup-qt
            pkgs-s.pince
          ];
        };
        hm = {
          home.packages = [
            pkgs-s.heroic
            pkgs-s.mangohud
            pkgs-s.protonup-qt
            pkgs-s.pince
          ];
        };
      })
      (lib-o.mkIf cfg.steam {
        os = {
          programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
            extraCompatPackages = [
              pkgs-u.proton-ge-bin
            ];
          };
          environment.systemPackages = [
            pkgs-s.bubblewrap
          ];
        };
      })
      (lib-o.mkIf cfg.vr {
        os = {
          environment.systemPackages = [
            pkgs-s.sidequest
            pkgs-s.android-tools
          ];
          services.monado = {
            enable = true;
            defaultRuntime = true;
          };
          services.wivrn = {
            enable = true;
            autoStart = true;
            highPriority = true;
            steam = {
              enable = true;
            };
          };
          systemd.user.services.monado.environment = {
            STEAMVR_LH_ENABLE = "1";
            XRT_COMPOSITOR_COMPUTE = "1";
          };
        };
      })
    ]
  );
}
