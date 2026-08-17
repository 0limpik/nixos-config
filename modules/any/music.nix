{
  config,
  osConfig,
  lib,
  lib-o,

  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.my.music;
in
{
  options.my.music = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    startup = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge (
      let
        spotify = pkgs-o.spotify-browser.override {
          browser = config.my.web.browser;
        };
      in
      [
        (lib-o.mkConfig (
          let
            packages = [
              pkgs-s.audacity
            ];
          in
          {
            os.environment.systemPackages = packages;
            hm.home.packages = packages ++ [
              spotify
            ];
          }
        ))
        (lib-o.mkIf cfg.startup {
          hm.my.wm.niri =
            let
              display = osConfig.my.wm.niri.display;
              output = if display.second != null then display.second else display.first;
            in
            {
              startups = ''
                ${config.my.wm.niri.run-visible} "${lib.getExe spotify}"
              '';
              workspaces = lib.mkOrder 900 ''
                workspace "music" {
                    open-on-output "${output}"
                }
              '';
              windows = ''
                window-rule {
                    match app-id=r#"^chrome-open.spotify.com__-Default$"#
                    open-on-workspace "music"
                    open-focused false
                }
              '';
            };
        })
      ]
    )
  );
}
