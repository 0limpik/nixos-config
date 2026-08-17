{
  system,
  config,
  osConfig,
  lib,
  lib-o,

  isSystem,
  inputs,
  pkgs-s,
  ...
}:
let
  cfg = config.my.wm;
in
{
  options.my.wm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    niri = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      display = {
        first = lib.mkOption {
          type = lib.types.str;
        };
        second =
          lib.mkOption {
            type = lib.types.str;
          }
          // (lib.optionalAttrs (osConfig == null) {
            default = "";
          });
      };
      startups = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
      };
      workspaces = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
      };
      windows = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
      };
      themes = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
      };
      run-visible = lib.mkOption {
        type = lib.types.str;
        default = "spawn-at-startup";
      };
    };
    vicinae = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (
        let
          plasma-sdk-wrapper =
            let
              plasma-sdk = pkgs-s.kdePackages.plasma-sdk;
            in
            pkgs-s.runCommand "${plasma-sdk.pname}-wrapper-${plasma-sdk.version}"
              {
                buildInputs = [
                  plasma-sdk
                ];
                nativeBuildInputs = [
                  pkgs-s.makeWrapper
                ];
              }
              ''
                mkdir --parents "$out/bin"
                for exe in "${plasma-sdk}/bin"/*; do
                  makeWrapper "$exe" "$out/bin/''${exe##*/}" \
                    --unset QT_STYLE_OVERRIDE
                done
                ln --symbolic "${plasma-sdk}/share" "$out/share"
              '';
          packages = [
            pkgs-s.xwayland-satellite
            pkgs-s.xdg-desktop-portal
            pkgs-s.kdePackages.polkit-kde-agent-1
            pkgs-s.kdePackages.xdg-desktop-portal-kde
            pkgs-s.swaylock
            pkgs-s.swayidle
            pkgs-s.playerctl
            pkgs-s.slurp
            pkgs-s.swaybg
            plasma-sdk-wrapper
          ];
        in
        lib-o.mkConfig {
          os = {
            environment.systemPackages = packages;
            security.rtkit.enable = true;
            xdg.portal.wlr = {
              enable = true;
              settings = {
                screencast = {
                  output_name = "DP-1";
                  max_fps = 30;
                  chooser_type = "simple";
                  chooser_cmd = "${lib.getExe pkgs-s.slurp} -o -r -f 'Monitor: %o' -b 00000000 -c FFFFFFFF -B 00000000";
                };
              };
            };
            security.polkit.enable = true;
            systemd.user.services.polkit-kde-agent-1 = {
              wantedBy = [
                "niri.service"
              ];
              after = [
                "graphical-session.target"
              ];
              partOf = [
                "graphical-session.target"
              ];
              serviceConfig = {
                Type = "simple";
                ExecStart = pkgs-s.writeShellScript "polkit-kde-agent-1" ''
                  unset QT_STYLE_OVERRIDE
                  "${pkgs-s.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
                '';
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
              };
            };
          };
          hm = {
            home.packages = packages;
            programs.swaylock.enable = true;
            services = {
              swayidle =
                with pkgs-s;
                let
                  lock = "${lib.getExe swaylock} --daemonize";
                  display = status: "${lib.getExe niri} msg action power-${status}-monitors";
                in
                {
                  enable = true;
                  timeouts = [
                    {
                      timeout = 300;
                      command = display "off";
                    }
                    {
                      timeout = 600;
                      command = lock;
                    }
                  ];
                  events = {
                    after-resume = display "on";
                  };
                };
            };
          };
        }
      )
      (lib-o.mkIf cfg.niri.enable {
        os = {
          programs.niri = {
            enable = true;
          };
          xdg.portal = {
            enable = true;
            configPackages = [
              pkgs-s.niri
            ];
            extraPortals = lib.mkForce [
              pkgs-s.kdePackages.xdg-desktop-portal-kde
              pkgs-s.xdg-desktop-portal-wlr
            ];
            config = rec {
              common = {
                "org.freedesktop.appearance" = "1";
                default = [
                  "kde"
                  "wlr"
                ];
              };
              niri = lib.mkForce (
                common
                // {
                  "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
                  "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
                }
              );
            };
          };
        };
        hm = {
          my.wm.niri = {
            startups = ''
              spawn-at-startup "${lib.getExe pkgs-s.swaybg}" "-m" "center" "-i" "${lib-o.local config}/wallpaper.png"
            '';
            run-visible = ''spawn-at-startup "${config.my.monitoring.run}" "niri"'';
          };
          xdg.configFile =
            let
              files = lib.attrNames (lib.readDir "${lib-o.local config}/niri");
              mkFile =
                file:
                lib.nameValuePair "niri/${file}" {
                  source = lib-o.mkSymlink config "niri/${file}";
                };
              autos = lib.filterAttrs (name: value: value != null) (
                with cfg.niri;
                {
                  inherit
                    startups
                    workspaces
                    windows
                    themes
                    ;
                }
              );
              mkAuto =
                name: value:
                lib.nameValuePair "niri/auto-${name}.kdl" {
                  text = value;
                };
            in
            (lib.listToAttrs (lib.map mkFile files)) // (lib.mapAttrs' mkAuto autos);
        };
      })
      (lib-o.mkIf cfg.vicinae.enable (
        let
          vicinae = inputs.vicinae.packages.${system}.default;
        in
        {
          any = {
            nix.settings = {
              substituters = [
                "https://vicinae.cachix.org"
              ];
              extra-trusted-public-keys = [
                "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
              ];
            };
          };
          os = {
            security.wrappers.vicinae-input-server = {
              owner = "root";
              group = "root";
              source = "${vicinae}/libexec/vicinae/vicinae-input-server";
              capabilities = "cap_sys_ptrace,cap_dac_override+ep";
            };
          };
          hm = {
            my.wm.niri.startups = ''
              spawn-at-startup "${lib.getExe vicinae}" "server";
            '';
            home.packages = [
              (pkgs-s.writeShellScriptBin "vicinae-launch-prefix" ''
                app_name="''${1:?app_name at first argumet is required}"
                app_arguments=("''${@:2}")

                for data_dir in ''${XDG_DATA_DIRS//:/ }; do
                  [[ -d "$data_dir/applications" ]] || continue

                  for desktop_path in "$data_dir/applications/"*.desktop; do
                    grep -iE "^(Exec|TryExec)=.*''${app_name}([[:space:]].*|$)" "$desktop_path" > /dev/null || continue

                    desktop_name="''${desktop_path##*/}"
                    desktop_name="''${desktop_name%.desktop}"
                    exec ${config.my.monitoring.run} "vicinae" "''${app_name}:''${desktop_name}" "''${app_arguments[@]}"
                  done
                done
                exec ${config.my.monitoring.run} "vicinae" "''${app_name}" "''${app_arguments[@]}"
              '')
            ];
            programs = {
              vicinae = {
                enable = true;
                package = vicinae;
                extensions = with inputs.vicinae-extensions.packages.${pkgs-s.stdenv.hostPlatform.system}; [
                  nix
                  power-profile
                  niri
                  pulseaudio
                ];
              };
            };
            xdg.configFile = {
              "vicinae/settings.json".source = lib-o.mkSymlink config "vicinae/settings.json";
            };
          };
        }
      ))
    ]
  );
}
