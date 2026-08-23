{
  config,
  osConfig,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.my.web;
in
{
  options.my.web = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    browser = lib.mkOption {
      type = lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      ({
        my.web.browser = pkgs-s.google-chrome;
        my.wm.niri =
          let
            windowName = "Main Browser";
          in
          {
            startups = ''
              ${config.my.wm.niri.run-visible} "${lib.getExe cfg.browser}:google-chrome" "--window-name=${windowName}"
            '';
            workspaces = lib.mkOrder 1150 ''
              workspace "browser" {
                  open-on-output "${(if osConfig ? my then osConfig else config).my.wm.niri.display.first}"
              }
            '';
            windows = ''
              window-rule {
                  match app-id=r#"^google-chrome$"# title=r#"^${windowName}$"#
                  open-on-workspace "browser"
                  open-maximized-to-edges true
                  open-focused true
              }
            '';
          };
      })
      (lib-o.mkConfig (
        let
          packages = [
            pkgs-s.curl
            pkgs-s.wget
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm.home.packages = packages;
        }
      ))
      (lib-o.mkIf config.my.wm.enable (
        let
          packages = [
            cfg.browser
            pkgs-s.qbittorrent
            pkgs-s.rustdesk
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm.home.packages = packages;
        }
      ))
    ]
  );
}
